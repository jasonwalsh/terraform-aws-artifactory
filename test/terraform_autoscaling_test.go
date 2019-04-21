package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
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
	options := &terraform.Options{
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": region,
		},
		TerraformDir: "..",
		VarFiles:     []string{"terraform.tfvars"},
		Vars: map[string]interface{}{
			"instance_type": "t2.micro",
		},
	}
	defer terraform.Destroy(t, options)
	test_structure.SaveString(t, "..", "region", region)
	test_structure.SaveTerraformOptions(t, "..", options)
	terraform.InitAndApply(t, options)
	t.Run("A=1", desiredCapacity)
}

// desiredCapacity ensures that the current number of instances matches the desired capacity of the group. Since the
// desired capacity is not defined, it should default to the minimum size of the group.
func desiredCapacity(t *testing.T) {
	options := test_structure.LoadTerraformOptions(t, "..")
	region := test_structure.LoadString(t, "..", "region")
	autoScalingGroupName := terraform.Output(t, options, "autoscaling_group_name")
	response := aws.GetCapacityInfoForAsg(t, autoScalingGroupName, region)
	expected := int64(1)
	actual := response.CurrentCapacity
	assert.Equal(t, expected, actual)
}
