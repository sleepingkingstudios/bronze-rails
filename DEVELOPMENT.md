# Development

- Responders
  - extract error key mapping to Responders::Errors.
  - JsonResponder: builds a JSON api response
- Add specs for Rails 5.1
- Move shared Rails file copying to CI step.
- Refactor Resource to use composition
  - Resource - defines names, associations, relations
  - ResourceBuilder - handles defining namespaces, parent resources: |

    Resource.new(Chapter) do
      namespace :admin
      namespace :api

      parent_resource :books, :class => 'Spec::Book'
    end # resource
    # implement e.g. ResourceBuilder.new(resource).instance_exec(&block)

  - ResourceRoutes - takes a Resource, defines routes
  - ResourceTemplates - takes a Resource, defines template paths

## Future Work

- I18nService
  - Handles locale-based fallback (en-gb, en)
  - Handles returned hash objects (e.g. when querying a sub-key).
- ResourcesController support for associations
  - Boss belongs to Dungeon, has one Enforcer, has many Minions
