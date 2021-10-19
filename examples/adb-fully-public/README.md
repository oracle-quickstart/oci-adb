## Create fully public Autonomous Database 
This example creates Autonomous Database (ADB) exposed to the public Internet. The code deployes the use-case defined [here](https://docs.oracle.com/en-us/iaas/adbnetworkaccess/access-control-rules-autonomous.html).
  
### Using this example
Update terraform.tfvars with the required information.

### Deploy the cluster  
Initialize Terraform:
```
$ terraform init
```
View what Terraform plans do before actually doing it:
```
$ terraform plan
```
Use Terraform to Provision resources:
```
$ terraform apply
```
