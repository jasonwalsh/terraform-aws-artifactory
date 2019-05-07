#cloud-config

packages:
  - java-1.8.0-openjdk-devel
  - jfrog-artifactory-pro

package_update: true

runcmd:
  - systemctl start artifactory
  - wget https://s3.amazonaws.com/amazoncloudwatch-agent/redhat/amd64/latest/amazon-cloudwatch-agent.rpm
  - rpm -U amazon-cloudwatch-agent.rpm
  - /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json ${start}

write_files:
  - content: ${cloudwatch}
    encoding: b64
    owner: root:root
    path: /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    permissions: 0644

yum_repos:
  bintray-jfrog-artifactory-pro-rpms:
    baseurl: https://jfrog.bintray.com/artifactory-pro-rpms
    enabled: 1
    gpgcheck: 0
    name: bintray--jfrog-artifactory-pro-rpms
    repo_gpgcheck: 0
