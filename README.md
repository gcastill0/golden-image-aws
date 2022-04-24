# Quick Start

1- Use the `Packer files` tab to explore the baseline template **ubuntu_base.pkr.hcl** and the assigned variables in **variables.pkr.hcl**. Notice a couple of things about this machine image release:

 - The Ubuntu release is Bionic 18.04
 - There is no record of the AMI release

2- Use the `Terminal` tab to explore the available images for Ubuntu and obtain the latest OS release to use in our Packer template:
```bash
aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=*minimal*hvm-ssd*focal*20*-amd64*2022*" \
  --query 'sort_by(Images, &CreationDate)[].Name' \
| jq -r '.[-1]'
```

2.1- Edit the file **variables.pkr.hcl** and replace the default value for the **image_name** variable with the latest Ubuntu minimal from Canonical. Your variable should look like this:

```bash
  default = "ubuntu-minimal/images/hvm-ssd/ubuntu-focal-20.04-amd64-minimal-2022*"
```

3- In a terminal, navigate to the working directory and set up the Packer environment:

```bash
packer init .
packer

3.1- Create a unique fingerprint and build the new machine image:

```bash
export HCP_PACKER_BUILD_FINGERPRINT="hashicat-demo-$(date +%s)"
packer validate .
packer build .
```

3.2- Confirm that we have an immage:

```bash
HASHICAT_IMAGE_ID=$( aws ec2 describe-images \
  --owners $AWS_ACCOUNT_ID \
| jq -r '.[] | .[] | .ImageId' )

echo $HASHICAT_IMAGE_ID
```

4- Navigate to the Terraform folder and use the $HASHICAT_IMAGE_ID as the input for the plan.

```bash
terraform init
terraform plan
```

4.1- Once we have a proper plan, deploy the new Web server:

```bash
terraform apply -auto-approve
```
