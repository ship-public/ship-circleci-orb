# CircleCI Orb for Ship

Welcome to Ship's CircleCI support! If you don't know what Ship is then take a look [at our website](https://www.shipapp.io/).

This project is an "Orb" for CircleCI. Orbs are CircleCI's way of providing plugins for your jobs.

**The latest version of Ship's Orb is 0.2.0**

## Prerequisites

Before you start to use the Ship CircleCI Orb you need to make sure you've completed a few tasks:

* You should already have setup your Github Organization to use Ship. You can [read how to do that here](https://www.shipapp.io/user-guide/#github).
  If you don't use Github then Ship can't help you at this time, but keep your eyes peeled 
  on [our Twitter](https://twitter.com/shipapp_).
 
* [Email us](mailto:hello@shipapp.io) to get your Orb API key.

* **Opt-in to use of third-party orbs on your CircleCI organization’s Security settings page**. 

* Identify a CircleCI workflow you want to integrate with Ship.

## Adding Ship to your CircleCI workflows

CircleCI doesn't support "organization-wide" plugins, and so you'll need to add Ship support explicitly
to each of your organization's workflows. Fortunately it's not too hard to do so.

1. First you'll need to put the API key from the prerequisites in an environment variable (`SHIP_API_KEY`). We recommend that 
you put it in an [organization-wide _Context_](https://circleci.com/docs/2.0/contexts/), but alternatively
   you can put it in your [project-specific settings](https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-project).
   
1. The remainder of the work is to update your workflow's CircleCI `config.yml` file. We'll explain by way of an example:

```yaml
description: Simple example
usage:
  version: 2.1
  # Welcome to Ship's CircleCI support! First add the orb reference.
  orbs:
    ship: ship-public/ship-orb@0.2.0

  jobs:
    build:
      docker:
        - image: your-image
      steps:
        # Put this step first to let Ship know your job has started. Make sure to set the "completed" flag to false
        - ship/notify:
            completed: false
        - all_of_your_job_commands
        # And put this step again at the end of the build for when the run is complete - note no ':' at the end of 
        # the command name if not specifying any params
        - ship/notify

  workflows:
    your-workflow:
      jobs:
        - build:
            # Typically you'll want to put your SHIP_API_KEY environment variable in a CircleCI Context,
            # and reference the context name here. Alternatively you can use a project-scope environment variable.
            # If you put it in a project-scope variable then no further change is needed to your project config file.
            context:
              - org-global
```

Once you've completed the changes to your project configuration then push the change to Github. On your next 
workflow run you should see your workflow appear automatically in your running version of Ship.

Assuming that this is working correctly the in Ship you can drill-down into workflows, link to runs and commits, 
communicate with your teammates about when things go wrong, and a [whole lot more](https://www.shipapp.io/features).

## Reference

Ship's page in the CircleCI Orb registry is [here](https://circleci.com/developer/orbs/orb/ship-public/ship-orb).

The Ship command has two parameters:

* `completed` is used to show whether the build has finished (`true` - the default value) or whether it is in
  progress (`false`)
* `org` : by default Ship uses the CircleCI "Project Username" as your Ship Organization name,
  since that is typically the same as your Github Organization. In case you need to override
  your Ship Org name you can either specify it with the `org` parameter, alternatively
  you can set the `SHIP_ORG` environment variable in your project settings, or organization context.

## Support

If you need any help please drop us a line at [support@shipapp.io](mailto:support@shipapp.io) .

Happy Shipping!
