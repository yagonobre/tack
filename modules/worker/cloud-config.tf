resource "template_file" "cloud-config" {

  template = <<EOF
#!/bin/bash

#Get s3-get-presigned
/usr/bin/mkdir -p /opt/bin
/usr/bin/curl -L -o /opt/bin/s3-get-presigned-url https://github.com/kz8s/s3-get-presigned-url/releases/download/v0.1/s3-get-presigned-url_linux_amd64
/usr/bin/chmod +x /opt/bin/s3-get-presigned-url

#Get SSL
/usr/bin/mkdir -p /etc/kubernetes/ssl
/usr/bin/curl $(/opt/bin/s3-get-presigned-url ${ region } ${ bucket } ${ ssl-tar }) | tar xv -C /etc/kubernetes/ssl/

#Run Cloudinit
/usr/bin/coreos-cloudinit --from-url=$(/opt/bin/s3-get-presigned-url ${ region } ${ bucket } user-data/worker)


EOF

  vars {
    bucket = "${ var.bucket-prefix }"
    region = "${ var.region }"
    ssl-tar = "/ssl/k8s-worker.tar"
  }
}
