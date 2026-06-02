# CS312 Course Project Part 2
#### Max Goldstein
#### goldstem@oregonstate.edu

## Background

This repository hosts  Terraform and Ansible configuration files used to deploy a Minecraft server to an EC2 instance on AWS with zero interaction with the AWS Management Console or by executing commands by connecting directly to the instance with SSH. This was the final assignment of CS312 at OSU. 

## Requirements

The following must be installed on the machine used to run the deployment scripts:

* Linux environment (tested with Ubuntu)
  * Windows users can use a Linux virtual machine
* AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* Terraform (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
* Ansible (https://docs.ansible.com/projects/ansible/latest/installation_guide/intro_installation.html)

Additionally, AWS credentials are required. For the purposes of this assignment, they are found in the AWS Learner Lab launch page under **AWS Details**.

After installing the AWS CLI, copy the provided credentials into:

```
~/.aws/credentials
```

You can verify this is working correctly with:

```
aws sts get-caller-identity
```

Which should return your account details.

---

## Initial Setup

Clone the repository:

```
git clone https://github.com/goldstem/CS312-Course-Project-Part-2.git
```

Navigate into the repository:

```
cd CS312-Course-Project-Part-2
```

---

# Terraform Deployment

Navigate to the Terraform directory:

```
cd terraform
```

Initialize Terraform:

```
terraform init
```

Review the execution plan to visualize changes:

```
terraform plan
```

Deploy:

```
terraform apply
```

And enter ```yes``` when prompted.



After deployment completes, you shold see the instance ID and public IP. If not, run this to see them:

```
terraform output
```

Record the instance ID and public IP address for later use.

Terraform will have created the following AWS resources:

* Ubuntu EC2 instance
* Security group
* SSH key pair (stored locally in the /terraform folder)

The SSH key is for Ansible and is not used for direct SSH access, though it can be for troubleshooting.

---

# Ansible Configuration

Copy the public IP address from the Terraform output and navigate to the Ansible directory:

```
cd ../ansible
```

Open the inventory file in your editor of choice:

```
nano inventory.ini
```

Replace the ```YOUR_INSTANCE_IP_HERE``` with the IP address of the newly created EC2 instance, and save and exit the file.

If Ansible reports SSH key permission errors, run the following to fix permissions:

```
chmod 600 ../terraform/minecraft-key.pem
```

Run the playbook:

```
ansible-playbook -i inventory.ini minecraft.yml
```

The playbook performs the following tasks automatically:

* Installs Java
* Creates the `/minecraft` directory
* Downloads the Minecraft server jar
* Accepts the Minecraft EULA
* Creates a systemd service
* Starts and enables the Minecraft service

Once the playbook completes successfully, the Minecraft server should be running.

---

# Test Connection

Verify that the Minecraft port is open and the service is running:

```
nmap -sV -Pn -p T:25565 <instance_public_ip>
```

If successful, the server should report port 25565 as open.

You can then connect using the Minecraft client:

```
<instance_public_ip>:25565
```
Keep in mind the version of the server you downloaded and make sure you are running the same version of Minecraft.

---

# Testing Automatic Startup

To verify that the service starts automatically after a reboot, restart the EC2 instance:

```
aws ec2 reboot-instances --instance-ids <instance_id>
```

The instance might take a few minutes to reboot. Then repeat the nmap and direct connections tests above.

---

# Sources

* Set up Terraform with AWS:
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create

* Set up Terraform AWS security group:
https://developer.hashicorp.com/terraform/tutorials/configuration-language/resource

* Set up Terraform AWS key pair and save it locally (for Ansible):
  * https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
  * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
  * https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file

* Install Java with Ansible:
https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/apt_module.html

* Create Minecraft Dir:
https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/file_module.html

* Download Minecraft Server:
https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/get_url_module.html

* Accept EULA:
https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/copy_module.html

* Create System Service for Minecraft:
https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/systemd_service_mod


