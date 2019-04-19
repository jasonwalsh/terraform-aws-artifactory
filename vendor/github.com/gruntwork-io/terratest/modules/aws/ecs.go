package aws

import (
	"fmt"
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/ecs"
	"github.com/stretchr/testify/require"
)

// GetEcsCluster fetches information about specified ECS cluster.
func GetEcsCluster(t *testing.T, region string, name string) *ecs.Cluster {
	cluster, err := GetEcsClusterE(t, region, name)
	if err != nil {
		t.Fatal(err)
	}
	return cluster
}

// GetEcsClusterE fetches information about specified ECS cluster.
func GetEcsClusterE(t *testing.T, region string, name string) (*ecs.Cluster, error) {
	client, err := NewEcsClientE(t, region)
	if err != nil {
		return nil, err
	}
	input := &ecs.DescribeClustersInput{
		Clusters: []*string{
			aws.String(name),
		},
	}
	output, err := client.DescribeClusters(input)
	if err != nil {
		return nil, err
	}

	numClusters := len(output.Clusters)
	if numClusters != 1 {
		return nil, fmt.Errorf("Expected to find 1 ECS cluster named '%s' in region '%v', but found '%d'",
			name, region, numClusters)
	}

	return output.Clusters[0], nil
}

// GetDefaultEcsClusterE fetches information about default ECS cluster.
func GetDefaultEcsClusterE(t *testing.T, region string) (*ecs.Cluster, error) {
	return GetEcsClusterE(t, region, "default")
}

// GetDefaultEcsCluster fetches information about default ECS cluster.
func GetDefaultEcsCluster(t *testing.T, region string) *ecs.Cluster {
	return GetEcsCluster(t, region, "default")
}

// CreateEcsCluster creates ECS cluster in the given region under the given name.
func CreateEcsCluster(t *testing.T, region string, name string) *ecs.Cluster {
	cluster, err := CreateEcsClusterE(t, region, name)
	if err != nil {
		t.Fatal(err)
	}
	return cluster
}

// CreateEcsClusterE creates ECS cluster in the given region under the given name.
func CreateEcsClusterE(t *testing.T, region string, name string) (*ecs.Cluster, error) {
	client := NewEcsClient(t, region)
	cluster, err := client.CreateCluster(&ecs.CreateClusterInput{
		ClusterName: aws.String(name),
	})
	if err != nil {
		return nil, err
	}
	return cluster.Cluster, nil
}

func DeleteEcsCluster(t *testing.T, region string, cluster *ecs.Cluster) {
	err := DeleteEcsClusterE(t, region, cluster)
	if err != nil {
		t.Fatal(err)
	}
}

// DeleteEcsClusterE deletes existing ECS cluster in the given region.
func DeleteEcsClusterE(t *testing.T, region string, cluster *ecs.Cluster) error {
	client := NewEcsClient(t, region)
	_, err := client.DeleteCluster(&ecs.DeleteClusterInput{
		Cluster: aws.String(*cluster.ClusterName),
	})
	return err
}

// NewEcsClient creates en ECS client.
func NewEcsClient(t *testing.T, region string) *ecs.ECS {
	client, err := NewEcsClientE(t, region)
	require.NoError(t, err)
	return client
}

// NewEcsClientE creates an ECS client.
func NewEcsClientE(t *testing.T, region string) (*ecs.ECS, error) {
	sess, err := NewAuthenticatedSession(region)
	if err != nil {
		return nil, err
	}

	return ecs.New(sess), nil
}
