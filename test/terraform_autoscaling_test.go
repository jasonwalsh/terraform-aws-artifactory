package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestAutoScalingGroupDesiredCapacity ensures that the current number of instances matches the desired capacity of the
// group. Since the desired capacity is not defined, it should default to the minimum size of the group.
func TestAutoScalingGroupDesiredCapacity(t *testing.T) {
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
	terraform.InitAndApply(t, options)
	autoScalingGroupName := terraform.Output(t, options, "autoscaling_group_name")
	response := aws.GetCapacityInfoForAsg(t, autoScalingGroupName, region)
	expected := int64(1)
	actual := response.CurrentCapacity
	assert.Equal(t, expected, actual)
}
