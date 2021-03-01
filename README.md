# sentia-data-engineering-assignment
see https://github.com/sentialabs/Data-Engineering

## Design

### Cloud choice

We note that requirement-wise, the inclusion of Microsoft PowerBI means that
we will at the very least require Microsoft Azure for our cloud setup.
It appears that presently our client's requirements
can be met without adding additional cloud providers,
so to simplify our PoC we will presently use just Azure.

### Infrastructure as Code (IaC)

However, our client has indicated that requirements may evolve over time,
so with that in mind, as well as to reduce vendor lock-in,
we will opt to implement our infrastructure-as-code PoC
using a cloud-agnostic tool, [Terraform](https://www.terraform.io/).

### Cloud infra design

[CloudSkew](https://cloudskew.com/) Design diagram:
![cloudskew-design-diagram](./sentia-infra-design.png)

### CI/CD design

Continuous Integration (CI) we would like to run on any commit or pull request.
In order to merge pull requests (PRs) into our `main` branch,
we will set up repository merging rules such as to require a successful CI run.

Continuous Deployment (CD) must be separated by environment,
going from development, to staging, to production.
These environments use different requirements:
while we might trigger deployment to the development environment on PR merge after a successful CI run (at minimum),
escalating such infrastructure changes to staging will require an integration test across our cloud infrastructure to succeed (at minimum),
whereas pushing changes from staging to production will additionally require manual testing (at minimum).

As we have opted for Terraform as our IaC tool,
we will therefore want set up Terraform environments in our CI/CD pipelines,
then run `terraform plan` in CI as an automated way of verification,
whereas we would run `terraform apply` in CD,
while ensuring the run will error in the event any parameter values are missing
(i.e. no interactive supplying variables on the console).

At the very least, our repository plus its CI/CD pipelines should likely remain independent of the infrastructure it is managing,
as it cannot depend on infrastructure it has yet to set up
(i.e. our client's Microsoft Azure cloud platform).
As such, this repository plus CI/CD should use any other existing infrastructure.

As this Proof of Concept (PoC) for the infrastructure-as-code will be available on Github as a private repository,
while the assignment allows us to design a pipeline independent of the delivery,
we will simply implement our CI/CD PoC using Github's built-in CI/CD capabilities in the form of [Github Actions](https://github.com/features/actions) as well,
which may immediately double as a functional CI on our PoC repository itself.

## Setup Instructions

- [Download and install](https://www.terraform.io/downloads.html) Terraform.
- [Download and install](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) the Azure CLI.
- Use `terraform login` to log in to Terraform Cloud,
as a way to store state for and collaborate on Terraform projects.
- Log in to [Terraform Cloud](https://app.terraform.io/) --
if the workspace has not been set up,
set your Azure credentials in its environment variables as described in the
[Terraform Azure guide](https://learn.hashicorp.com/tutorials/terraform/azure-remote?in=terraform/azure-get-started#configure-a-service-principal).
- In this GitHub repository ensure the secrets required for the [Terraform Github Action](https://github.com/marketplace/actions/hashicorp-setup-terraform) are set.
- [Pass values](https://www.terraform.io/docs/language/values/variables.html#assigning-values-to-root-module-variables) for variables listed in `variables.tf`, e.g. by renaming `terraform.auto.tfvars.example` to `terraform.auto.tfvars` and filling its contents, adding additional variable values as needed.

## Usage

- Initialize a new or existing Terraform configuration:
  `terraform init`

- Verify that the configuration files are syntactically valid:
  `terraform validate`

- Generate and show an execution plan:
  `terraform plan`

- Build or change infrastructure:
  `terraform apply`

- Destroy Terraform-managed infrastructure:
  `terraform destroy`

In order to trigger the CI/CD pipelines, please create a Github pull-request
using the changes you would like to see to the infrastructure.
