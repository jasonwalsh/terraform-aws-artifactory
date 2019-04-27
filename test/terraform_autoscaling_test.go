package test

import (
	"fmt"
	"net/http"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestArtifactoryAutoScalingGroup contains setup and teardown functions to prevent expensive repeating calls to create
// and destroy the infrastructure via Terraform. The subtests run once the setup function completes successfully. The
// cleanup function is deferred, so if any of the subtests fail, then the infrastructure is automatically destroyed to
// prevent incurring any additional costs.
func TestArtifactoryAutoScalingGroup(t *testing.T) {
	region := aws.GetRandomStableRegion(t, nil, nil)
	keyPair := aws.CreateAndImportEC2KeyPair(t, region, random.UniqueId())
	options := &terraform.Options{
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
		TerraformDir: "..",
		Vars: map[string]interface{}{
			"allow_ssh":                   true,
			"associate_public_ip_address": true,
			"cidr_block":                  "10.0.0.0/16",
			"create_key_pair":             false,
			"instance_type":               "t2.medium",
			"key_name":                    keyPair.Name,
			"max_size":                    1,
			"min_size":                    1,
		},
	}
	defer func() {
		terraform.Destroy(t, options)
		aws.DeleteEC2KeyPair(t, keyPair)
	}()
	test_structure.SaveString(t, "..", "region", region)
	test_structure.SaveTerraformOptions(t, "..", options)
	test_structure.SaveEc2KeyPair(t, "..", keyPair)
	terraform.InitAndApply(t, options)
	t.Run("A=DesiredCapacity", DesiredCapacity)
	t.Run("A=ServiceIsRunning", ServiceIsRunning)
	t.Run("A=HealthCheck", HealthCheck)
}

// DesiredCapacity ensures the number of EC2 instances that should be running in the Auto Scaling group.
func DesiredCapacity(t *testing.T) {
	options := test_structure.LoadTerraformOptions(t, "..")
	region := test_structure.LoadString(t, "..", "region")
	autoScalingGroupName := terraform.Output(t, options, "autoscaling_group_name")
	response := aws.GetCapacityInfoForAsg(t, autoScalingGroupName, region)
	expected := int64(1)
	actual := response.CurrentCapacity
	assert.Equal(t, expected, actual)
}

// ServiceIsRunning ensures the Artifactory service is running.
func ServiceIsRunning(t *testing.T) {
	options := test_structure.LoadTerraformOptions(t, "..")
	keyPair := test_structure.LoadEc2KeyPair(t, "..")
	region := keyPair.Region
	autoScalingGroupName := terraform.Output(t, options, "autoscaling_group_name")
	instanceIds := aws.GetInstanceIdsForAsg(t, autoScalingGroupName, region)
	publicIPAddress := aws.GetPublicIpOfEc2Instance(t, instanceIds[0], region)
	userProfile := ssh.Host{Hostname: publicIPAddress, SshKeyPair: keyPair.KeyPair, SshUserName: "ubuntu"}
	expected := "active"
	retry.DoWithRetry(t, "ServiceIsRunning", 60, time.Second, func() (string, error) {
		actual, err := ssh.CheckSshCommandE(t, userProfile, "/opt/jfrog/artifactory/bin/artifactoryctl check")
		actual = strings.Replace(actual, "\n", "", -1)
		if err != nil {
			return "", err
		}
		assert.Equal(t, expected, actual)
		return "", nil
	})
}

// HealthCheck ensures the Artifactory health check is running.
func HealthCheck(t *testing.T) {
	options := test_structure.LoadTerraformOptions(t, "..")
	dnsName := terraform.Output(t, options, "dns_name")
	url := fmt.Sprintf("http://%s:%d/artifactory/api/system/ping", dnsName, 8081)
	http_helper.HttpGetWithRetry(t, url, http.StatusOK, "OK", 60, time.Second)
}
