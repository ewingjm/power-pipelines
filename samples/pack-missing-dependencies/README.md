# Pack missing dependencies

- [Pack missing dependencies](#pack-missing-dependencies)
  - [Introduction](#introduction)
  - [Sample](#sample)

## Introduction

The `MissingDependencies` elements in the _Solution.xml_ are a frequent cause of merge conflicts when developers are merging solution changes independently. In the event that you are using the [split-missing-dependencies-steps.yml](../../steps/split-missing-dependencies-steps.yml) template to address this problem (as documented in the [README.md](../../README.md)), you will need to update the build process to ensure the unpacked missing dependencies are being repacked for the Solution Packager executes.

## Sample

Move the [Directory.Build.targets](./Directory.Build.targets) into a folder where all of your *.cdsproj solution projects are descendants. For example, _src/solutions/Directory.Build.props_ (where your solution projects are nested under _src/solutions_).

If you are already using a _Directory.Build.targets_, copy the contents of this into your file instead.