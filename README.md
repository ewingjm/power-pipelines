# PowerPipelines

Azure Pipelines templates that provide an end-to-end DevOps framework for Power Apps.

## Table of contents

- [PowerPipelines](#powerpipelines)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage)
    - [Create development environment](#create-development-environment)
    - [Sync solution metadata](#sync-solution-metadata)
    - [Validate package](#validate-package)
    - [Build package](#build-package)
    - [Deploy packages](#deploy-packages)
    - [Delete work item environments](#delete-work-item-environments)
  - [Contributing](#contributing)


## Introduction

This repository provides all the pipeline templates necessary for the end-to-end delivery of a Power Platform project via Azure DevOps. It is aimed at hybrid or pro-dev teams seeking to adopt modern DevOps practices. 

Using these templates, your projects can:

- Provision development environments for work items
- Sync solution metadata to Git
- Provision test environments for pull requests
- Track environments linked to work items
- Automatically delete environments on completion of work items
- Deploy to static environments

The use of ephemeral development and test environments allows your team to develop and test work items in isolation. This helps to ensure a more stable build as well as a more scalable delivery. 

## Prerequisites

These pipelines assume fully automated deployments via the Package Deployer. You must have a Package Deployer package project created via the Power Apps CLI.

## Usage

This section details the pipeline templates that are available.

### Create development environment

[`create-development-environment-pipeline.yml`](./pipelines/create-development-environment-pipeline.yml)

Creates a development environment for a given solution within a package. 

[Example](./samplespipelines/create-development-environment.yml)

| Parameter                              | Description                                                                                                                                                                                                                                |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| workItemId                             | The Azure DevOps work item ID associated with the environment.                                                                                                                                                                             |
| displayNamePrefix                      | The display name prefix for the environment. Additional metadata will be automatically appended to the display name.                                                                                                                       |
| domainNamePrefix                       | The domain name prefix for the environment. Additional metadata will be automatically appended to the domain name.                                                                                                                         |
| packageProject                         | The path to the Package Deployer package project created via the Power Apps CLI.                                                                                                                                                           |
| solution                               | The unique name of the solution to provision the development environment for.                                                                                                                                                              |
| serviceConnection                      | The Power Platform service connection to use. This should be a [management app](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal#registering-an-admin-management-application) service principal. |
| securityGroupId **[optional]**         | The ID of the security group to assign to the environment.                                                                                                                                                                                 |
| prepareEnvironmentJobs **[optional]**  | Additional jobs that should be ran after the environment is provisioned but prior to the deployment. These jobs have access to the `BuildTools.EnvironmentUrl` and `BuildTools.EnvironmentId` variables that point to the new environment. |
| finaliseEnvironmentJobs **[optional]** | Additional jobs that should be ran after the environment is deployed to. These jobs have access to the `BuildTools.EnvironmentUrl` and `BuildTools.EnvironmentId` variables that point to the new environment.                             |
| templates **[optional]**               | Refers to the `AppsTemplate` parameter of the [Create Environment](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tool-tasks#power-platform-create-environment) task in the Power Platform Build Tools.                 |
| location **[optional]**                | Refers to the `LocationName` parameter of the [Create Environment](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tool-tasks#power-platform-create-environment) task in the Power Platform Build Tools.                 |
| language **[optional]**                | Refers to the `LanguageName` parameter of the [Create Environment](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tool-tasks#power-platform-create-environment) task in the Power Platform Build Tools.                 |
| currency **[optional]**                | Refers to the `CurrencyName` parameter of the [Create Environment](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tool-tasks#power-platform-create-environment) task in the Power Platform Build Tools.                 |
| config **[optional]**                  | The path to a Package Deployer import configuration file (relative to the root of the package). Useful when you require a different package configuration for development environments.                                                    |
| branch **[optional]**                  | The name of a Git branch to create at the commit from which the environment was provisioned.                                                                                                                                               |
| dotNetSdkVersion **[optional]**        | The .NET SDK version to use to build the package. Defaults to 6.x.                                                                                                                                                                        |

Note that all solutions within the package (if any) other than the given solution will be imported as managed. The development environment (and branch if specified) will be linked to the work item identified by `workItemId`.

### Sync solution metadata

[`sync-solution-metadata-pipeline.yml`](./pipelines/sync-solution-metadata-pipeline.yml) 

Syncs the metadata for a given solution.

[Example](./samplespipelines/deploy-to-test.yml)

| Parameter                      | Description                                                                                 |
| ------------------------------ | ------------------------------------------------------------------------------------------- |
| url                            | The URL of the environment to sync from.                                                    |
| solution                       | The unique name of the solution to sync.                                                    |
| outputDirectory                | The output directory for synced metadata.                                                   |
| serviceConnection              | The service connection to use.                                                              |
| commitMessage                  | The commit message.                                                                         |
| branch                         | The target branch.                                                                          |
| postUnpackSteps **[optional]** | Additional steps that should be ran after the unpack operation. See below for more details. |
| mapFile **[optional]**         | The path to the solution mapping file.                                                      |
 

The `postUnpackSteps` parameter can be used to extend the extract process. The Solution Packager alone is not always sufficient to avoid recurrent conflicts with pull requests. 
For example, pull requests updating the same solution(s) will frequently generate conflicts that are difficult to resolve around the `MissingDependencies` elements of the _Solution.xml_. 
A step [template](./steps/split-missing-dependencies-steps.yml) has been created to further unpack the missing dependencies into their own individual files. This makes conflicts much easier to resolve.
Note that any changes to the unpack process will also need changes to the pack process. Refer to the _pack missing dependencies_ sample [README.md](./samplespack-missing-dependencies/README.md)

### Validate package

[`validate-package-pipeline.yml`](./pipelines/validate-package-pipeline.yml) 

A validation pipeline template that can build and deploy changes in a pull request to an environment.

[Example](./samplespipelines/validate-package.yml)

| Parameter                                  | Description                                                                                                                                                                                                                                 |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| serviceConnection                          | The Power Platform service connection to use. This should be a [management app](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal#registering-an-admin-management-application) service principal.  |
| packageProject                             | The path to the Package Deployer package project created via the Power Apps CLI.                                                                                                                                                            |
| displayNamePrefix                          | The display name prefix for the environment. Additional metadata will be automatically appended to the display name.                                                                                                                        |
| domainNamePrefix                           | The domain name prefix for the environment. Additional metadata will be automatically appended to the domain name.                                                                                                                          |
| solutionSourcePattern                      | File pattern to identify when an update to solution metadata occurs. Supports `*` as a wildcard.                                                                                                                                            |
| packageSourcePatterns                      | File patterns to identify when an update to the package template occurs. Supports `*` as a wildcard.                                                                                                                                        |
| filesToAnalyse **[optional]**              | File pattern to identify solutions to check with the Solution Checker. Defaults to all '**/*.zip'.                                                                                                                                          |
| webResourceSourcePatterns **[optional]**   | File patterns to identify when an update to web resources occurs. Supports `*` as a wildcard.                                                                                                                                               |
| assemblySourcePatterns **[optional]**      | File patterns to identify when an update to plug-in assembly occurs. Supports `*` as a wildcard.                                                                                                                                            |
| additionalPatterns **[optional]**          | File patterns to identify when other kinds of updates occur. See below for details.                                                                                                                                                         |
| securityGroupId **[optional]**             | The ID of the security group to assign to the validation environment.                                                                                                                                                                       |
| templates **[optional]**                   | Refers to the `AppsTemplate` parameter of the [Create Environment](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tool-tasks#power-platform-create-environment) task in the Power Platform Build Tools.                  |
| location **[optional]**                    | Refers to the `LocationName` parameter of the [Create Environment](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tool-tasks#power-platform-create-environment) task in the Power Platform Build Tools.                  |
| language **[optional]**                    | Refers to the `LanguageName` parameter of the [Create Environment](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tool-tasks#power-platform-create-environment) task in the Power Platform Build Tools.                  |
| currency **[optional]**                    | Refers to the `CurrencyName` parameter of the [Create Environment](https://learn.microsoft.com/en-us/power-platform/alm/devops-build-tool-tasks#power-platform-create-environment) task in the Power Platform Build Tools.                  |
| config **[optional]**                      | The path to a Package Deployer import configuration file (relative to the root of the package). Useful when you require a different package configuration for validation environments.                                                      |
| prepareEnvironmentJobs **[optional]**      | Additional jobs that should be ran after the environment is provisioned but prior to the deployment. These jobs have access to the `BuildTools.EnvironmentUrl` and `BuildTools.EnvironmentId` variables that point to the new environment.  |
| finaliseEnvironmentJobs **[optional]**     | Additional jobs that should be ran after the environment is deployed to. These jobs have access to the `BuildTools.EnvironmentUrl` and `BuildTools.EnvironmentId` variables that point to the new environment.                              |
| testJobs **[optional]**                    | Additional automated test jobs that should be ran after the environment is deployed to and finalised. These jobs have access to the `BuildTools.EnvironmentUrl` and `BuildTools.EnvironmentId` variables that point to the new environment. |
| dotNetSdkVersion **[optional]**            | The .NET SDK version to use to build the package. Defaults to 6.x.                                                                                                                                                                         |

The validation pipeline builds the package, analyses the updates, runs the Solution Checker (if any solutions have been updated), creates an environment, deploys to the environment, and waits for manual validation. This allows for changes to be built, deployed, and tested before merging to main.

In the event that you are executing automating tests, these can be ran as part of the `testJobs`. Jobs passed to `prepareEnvironmentJobs`, `finaliseEnvironmentJobs`, and `testJobs` have access to the `BuildTools.EnvironmentUrl` and `BuildTools.EnvironmentId` variables that point to the newly created environment.

The `solutionSourcePattern`, `packageSourcePatterns`, `webResourceSourcePatterns`, and `assemblySourcePatterns` enable the validation pipeline to determine when it is necessary to test the deployment of the package. If the package or solution aren't impacted by the changes, the deployment and related stages will be skipped. These parameters also enable the pipeline to set a number of output variables:

- `GetSolutionUpdates.Solution.IsUpdated`
- `GetSolutionUpdates.Backend.IsUpdated`
- `GetSolutionUpdates.Frontend.IsUpdated`
- `GetPackageTemplateUpdated.IsUpdated`

These variables are outputted in the `AnalyseUpdates` job of the `AnalyseUpdates` stage. Internally, these variables are used to conditionally execute the stages that create and deploy to an environment. You may wish to use these output variables for your own purposes (e.g., running integration tests only when `GetSolutionUpdates.Backend.IsUpdated` is `true` given that integration tests aren't impacted by UI changes).

The `additionalPatterns` parameter can be used for any scenarios not covered above. It is an array of objects with the following properties:

| Property        | Description                                                                                       |
| --------------- | ------------------------------------------------------------------------------------------------- |
| filePatterns    | An array of strings. File patterns to identify when an update occurs. Supports `*` as a wildcard. |
| stepName        | The name of the step. Used to refer to the output variable created for this step.                 |
| stepDisplayName | The display name of the step.                                                                     |

To refer to the output variables created by patterns passed with `additionalPatterns`, use `<stepName>.IsUpdated`.

### Build package

[`build-package-pipeline.yml`](./pipelines/build-package-pipeline.yml)

Builds a Package Deployer package (i.e. a package project that has been created using the Power Apps CLI) and analyses the solutions with the Solution Checker. 

[Example](./samplespipelines/build-package.yml)

| Parameter                                  | Description                                                                                              |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| serviceConnection                          | The name of an Azure DevOps Power Platform service connection.                                           |
| packageProject                             | The path to the Package Deployer MSBuild project.                                                        |
| filesToAnalyse **[optional]**              | The pattern to match solution zip files to analyse with the Solution Checker. Defaults to all zip files. |
| dotNetSdkVersion **[optional]**            | The .NET SDK version to use to build the package. Defaults to 6.x.                                      |

The managed package is published as an artifact named `package`.

This template uses GitVersion to version the build. Please ensure that you have a properly configured GitVersion.yml file in the root of your repository. Below is an example GitVersion.yml that uses GitVersion's [mainline](https://gitversion.net/docs/reference/modes/mainline) mode [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). This approach assumes you keep your main branch deployable to production at all times (recommended).

```yaml
mode: mainline
major-version-bump-message: "(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\\([\\w\\s]*\\))?!:"
minor-version-bump-message: "(feat)(\\([\\w\\s]*\\))?:"
patch-version-bump-message: "(build|chore|ci|docs|fix|perf|refactor|revert|style|test)(\\([\\w\\s]*\\))?:"
```

This template does **not** handle the versioning of your Dataverse solutions. It will only version the package as a whole. For information on how to version your solutions, refer to [PowerVersion](https://github.com/ewingjm/power-version)

At the time of writing, the packing of solution projects created via the Power Apps CLI requires a separate MappingFile.xml to the unpack operation. This is due to the fact that the pack operation happens on a copy of the metadata folder that has been copied to the intermediate output path (_obj_). Refer to the _transform mapping directives_ sample [README.md](./samplestransform-mapping-directives/README.md) for a solution to this problem.

### Deploy packages

[`deploy-packages-pipeline.yml`](./pipelines/deploy-packages-pipeline.yml)

Deploys one or more Package Deployer packages to an environment.

[Example](./samplespipelines/deploy-to-test.yml)

| Parameter                         | Description                                                                                                                                                         |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| serviceConnection                 | The Power Platform service connection to use.                                                                                                                       |
| environment                       | The name of the environment to deploy to. Refer to [Environments](https://learn.microsoft.com/en-us/azure-devops/pipelines/process/environments?view=azure-devops). |
| packages                          | The package(s) to deploy. This is an object array - refer below for more information.                                                                               |
| url **[optional]**                | The URL of the environment to deploy to. Defaults to the URL in the service connection.                                                                             |
| tagSuccess **[optional]**         | Whether to tag the pipeline resources on a successful deployment with a `Deployed to <environment>` tag. Defaults to `false`.                                       |
| postDeploymentJobs **[optional]** | Additional jobs that should be ran after the environment is deployed to.                                                                                            |

The `packages` parameter is an array of objects which can contain the below properties

| Property                           | Description                                                                                                                                                                           |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| resource                           | The name of the pipeline resource that contains the package artifact.                                                                                                                 |
| artifact                           | The name of the name of the artifact that contains the package.                                                                                                                       |
| file                               | The path to the package assembly (relative to the root of the artifact).                                                                                                              |
| config **[optional]**              | The path to a Package Deployer import configuration file (relative to the root of the package). Useful when you require a different package configuration for different environments. |
| preDeploymentSteps **[optional]**  | Additional steps that should be ran before the package is deployed.                                                                                                                   |
| postDeploymentSteps **[optional]** | Additional steps that should be ran after the package is deployed.                                                                                                                    |
| dependsOn **[optional]**           | The packages that this package depends on. Reference other packages using the name of the pipeline resource that contains the package.                                                |

Please note that the version generated for the runs of any pipelines that extend this template will be calculated by summing the versions of each of the resources.

### Delete work item environments

[`delete-work-item-environments-pipeline.yml`](./pipelines/delete-work-item-environments-pipeline.yml)

Deletes environments (created by pipelines extending other templates in this repository) that are linked to work items in a given category state.

[Example](./samplespipelines/delete-inactive-work-item-environments.yml)

| Parameter                | Description                                                                                                                                                                                                                                |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| serviceConnection        | The Power Platform service connection to use. This should be a [management app](https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal#registering-an-admin-management-application) service principal. |
| categoryStates           | The [category states](https://learn.microsoft.com/en-us/azure-devops/boards/work-items/workflow-and-state-categories?view=azure-devops&tabs=agile-process#category-states) used to filter work items to delete related environments for.   |
| metadata **[optional]**  | Used to filter which environments to delete based on additional metadata (see below).                                                                                                                                                      |
| createdBy **[optional]** | Used to filter which environments to delete based on the Azure AD object ID of a principal that created them.                                                                                                                              |

It is recommended to run the pipeline(s) that extend this template on a fairly regular schedule (e.g. once per day). Ensure that the `categoryStates`, `metadata`, and `createdBy` filters are sufficient to avoid deleting environments unintentionally.

You can pass the following to the `metadata` property.

| Property    | Description                                                                      |
| ----------- | -------------------------------------------------------------------------------- |
| environment | The type of environment. Allowed values are: `development`.                      |
| pipeline    | The name of the pipeline that created the environment.                           |
| runId       | The ID of the pipeline run that created the environment.                         |
| repo        | The name of the repository containing the pipeline that created the environment. |
| repoId      | The ID of the repository containing the pipeline that created the environment.   |

For example:

```yaml
metadata:
  environment: development
  repo: contoso-sales
```

This will ensure that only environments created by the [Create development environment](#create-development-environment) pipeline template from a pipeline in the `contoso-sales` repository are deleted.

## Contributing

Refer to the contributing [guide](./CONTRIBUTING.md).