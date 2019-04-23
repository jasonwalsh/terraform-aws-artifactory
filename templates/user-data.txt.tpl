#cloud-config

apt:
  sources:
    artifactory.list:
      keyid: 6B219DCCD7639232
      source: "deb https://jfrog.bintray.com/artifactory-pro-debs xenial main"

packages:
  - default-jdk
  - default-jre
  - jfrog-artifactory-pro

package_update: true

runcmd:
  - systemctl start artifactory
