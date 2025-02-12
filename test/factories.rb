FactoryBot.define do
  factory :ad_hoc_domain do
    sequence(:name) { |n| "Ad Hoc Domain #{n}" }
    eventsource
    eventcategory
    association :connected_property, factory: :property
  end

  factory :ad_hoc_domain_cycle do
    sequence(:name) { |n| "Ad Hoc Domain Cycle #{n}" }
    ad_hoc_domain
    starts_on { Date.today }
    exclusive_end_date { Date.today + 3.days }
  end

  factory :ad_hoc_domain_subject do
    subject
    ad_hoc_domain_cycle
  end

  factory :ad_hoc_domain_staff do
    staff
    ad_hoc_domain_cycle
  end

  factory :ad_hoc_domain_subject_staff do
    transient do
      ad_hoc_domain_cycle { create(:ad_hoc_domain_cycle) }
    end
    ad_hoc_domain_staff { create(:ad_hoc_domain_staff, ad_hoc_domain_cycle: ad_hoc_domain_cycle) }
    ad_hoc_domain_subject { create(:ad_hoc_domain_subject, ad_hoc_domain_cycle: ad_hoc_domain_cycle) }
  end

  factory :ad_hoc_domain_pupil_course do
    ad_hoc_domain_subject_staff
    pupil
  end

  factory :attachment do
    parent_id { 1 }
    parent_type { "MyString" }
    user_file_id { 1 }
  end

  factory :era do
    sequence(:name) { |n| "Era number #{n}" }
    starts_on       { Date.today }
    ends_on         { Date.today + 1.year }
  end

  factory :property do
    transient do
      owner { nil }
    end

    sequence(:name) { |n| "Property number #{n}" }
    after(:create) do |property, evaluator|
      if evaluator.owner
        #
        #  The requester would like this to be an owned property,
        #  which means creating a Concern linking it to the indicated
        #  owner.
        #
        property.element.concerns.create!({
          user: evaluator.owner,
          owns: true,
          colour: evaluator.owner.free_colour
        })
      end
    end
  end

#
#  If you try to create an element on its own, it will get a Property
#  as its entity.
#
  factory :element do
    sequence(:name) { |n| "Element number #{n}" }
    association :entity, factory: :property
  end

#
#  Note that we don't need to specify Element records within our
#  entities.  They will be added automatically when the entity is
#  saved to the database.
#
#  Here FactoryBot differs from fixtures.  With fixtures you need
#  to create the link explicitly because they go around the back of
#  the models and shove stuff in the database directly.
#
  factory :group do
    transient do
      chosen_persona { 'Vanillagrouppersona' }
    end

    sequence(:name) { |n| "Group number #{n}" }
    era
    #
    #  I would really like to be able to pass the group's name to the
    #  element so it can have the same name, but this seems to be one
    #  of those things that is damn near impossible with FactoryBot -
    #  or maybe it's just not documented.
    #
    starts_on     { Date.today }
    add_attribute(:persona_class) { chosen_persona }
    current { true }
  end

  factory :location do
    transient do
      owner { nil }
    end

    sequence(:name) { |n| "Location number #{n}" }
    active { true }
    after(:create) do |location, evaluator|
      if evaluator.owner
        #
        #  The requester would like this to be an owned location,
        #  which means creating a Concern linking it to the indicated
        #  owner.
        #
        location.element.concerns.create!({
          user: evaluator.owner,
          owns: true,
          colour: evaluator.owner.free_colour
        })
      end
    end
  end

  factory :locationalias do
    sequence(:name) { |n| "Location alias #{n}" }
  end

  factory :staff do
    sequence(:name) { |n| "Staff member #{n}" }
    sequence(:initials) { |n| "SM#{n}" }
    active { true }
    current { true }
    teaches { true }
  end

  factory :pupil do
    sequence(:name) { |n| "Pupil #{n}" }
    current { true }
  end

  factory :service do
    sequence(:name) { |n| "Resource / Service #{n}" }
  end

  factory :subject do
    sequence(:name) { |n| "Subject #{n}" }
    datasource
  end

  factory :user_profile do
    sequence(:name) { |n| "User profile #{n}" }
    known { true }
    transient do
      godlike_permissions { false }
    end
    trait :godlike do
      godlike_permissions { true }
    end
    permissions do
      hash = {}
      if godlike_permissions
        PermissionFlags::KNOWN_PERMISSIONS.each do |pf|
          hash[pf] = true
        end
      end
      hash
    end
  end

  factory :user do
    sequence(:name) { |n| "User number #{n}" }
    sequence(:email) { |n| "user#{n}@myschool.org.uk" }
    #
    #  We have to be quite clever to allow privilege flags to be set
    #  via traits individually.  They all need to end up in the same
    #  hash.
    #
    #  First we create some transient variables with default values.
    #
    transient do
      permissions_admin       { false }
      permissions_editor      { false }
      permissions_privileged  { false }
      permissions_api         { false }
      permissions_noter       { false }
      permissions_files       { false }
      permissions_su          { false }
      permissions_memberships { false }
      permissions_exams       { false }
      permissions_have_forms  { false }
      permissions_view_forms  { false }
      #
      #  Getting slightly odd.
      #
      #  The thing to understand here is that if you don't specify
      #  either editor or not_editor then the user's edit permission
      #  will be inherited from the user profile.
      #
      permissions_not_editor        { false }
      permissions_not_can_roam      { false }
      permissions_not_add_resources { false }
    end

    #
    #  Then traits to allow us to change those values
    #
    trait :admin do
      permissions_admin { true }
    end

    trait :editor do
      permissions_editor { true }
    end

    trait :not_editor do
      permissions_not_editor { true }
    end

    trait :not_can_roam do
      permissions_not_can_roam { true }
    end

    trait :not_add_resources do
      permissions_not_add_resources { true }
    end

    trait :privileged do
      permissions_privileged { true }
    end

    trait :api do
      permissions_api { true }
    end

    trait :noter do
      permissions_noter { true }
    end

    trait :files do
      permissions_files { true }
    end

    trait :su do
      permissions_su { true }
    end

    trait :memberships do
      permissions_memberships { true }
    end

    trait :does_exams do
      permissions_exams { true }
    end

    trait :have_forms do
      permissions_have_forms { true }
    end

    trait :view_forms do
      permissions_view_forms { true }
    end

    firstday { 0 }
    user_profile { UserProfile.guest_profile }

    permissions do
      #
      #  And now use those transient values to build our
      #  permissions hash, all in one go.
      #
      hash = {}
      if permissions_admin
        hash[:admin] = true
      end
      if permissions_editor
        hash[:editor] = true
      end
      #
      #  Leaving hash[:editor] unset is not the same thing as
      #  setting it to false.  Unset means "inherit from profile"
      #  whilst false means "override profile - not an editor".
      #
      if permissions_not_editor
        hash[:editor] = false
      end
      if permissions_not_can_roam
        hash[:can_roam] = false
      end
      if permissions_not_add_resources
        hash[:can_add_resources] = false
      end
      if permissions_privileged
        hash[:privileged] = true
      end
      if permissions_api
        hash[:can_api] = true
      end
      if permissions_noter
        hash[:can_add_notes] = true
      end
      if permissions_files
        hash[:can_has_files] = true
      end
      if permissions_su
        hash[:can_su] = true
      end
      if permissions_memberships
        hash[:can_edit_memberships] = true
      end
      if permissions_exams
        hash[:exams] = true
      end
      if permissions_have_forms
        hash[:can_has_forms] = true
      end
      if permissions_view_forms
        hash[:can_view_forms] = true
      end
      hash
    end

    factory :admin_user, traits: [:admin]
    #
    #  In order to behave like the session controller when creating
    #  a new user record we need to call find_matching_resources too.
    #
    after(:create) do |u|
      u.find_matching_resources
    end
  end

  factory :concern_set do
    association :owner, factory: :user
    sequence(:name) { |n| "Concern set #{n}" }
  end

  factory :concern do
    user
    element
    colour { 'blue' }
  end

  factory :datasource do
    sequence(:name) { |n| "Data source #{n}" }
  end

  factory :eventcategory do
    sequence(:name) { |n| "Event category #{n}" }
    pecking_order   { 10 }
    #
    #  And some sensible ordinary defaults
    #
    schoolwide             { false }
    publish                { true }
    unimportant            { false }
    #
    #  The rest have defaults in the d/b anyway.
    #
  end

  factory :eventsource do
    sequence(:name) { |n| "Event source #{n}" }
  end

  factory :event do
    transient do
      #
      #  To add resources to your new event, pass them in to
      #  these two.
      #
      #  For commitments, pass an array of entities (not elements).
      #  For requests, pass a hash of entity + quantity.
      #
      #  E.g. { Minibus => 2, Mobile phone => 1 }
      #
      #  A bit odd to use a whole ActiveRecord object as the key,
      #  but this only a test harness.  As long as it works,...
      #  and apparently it does.
      #
      commitments_to { [] }
      requests_for { {} }
    end

    sequence(:body) { |n| "Event #{n}" }
    eventcategory
    eventsource
    owner     { nil }   # System event by default
    starts_at { Time.now }
    ends_at   { Time.now + 1.hour }

    after(:create) do |event, evaluator|
      evaluator.commitments_to.each do |resource|
        event.commitments.create({
          element: resource.element
        }) do |commitment|
          if evaluator.owner
            commitment.set_appropriate_approval_status_for(
              evaluator.owner)
          end
        end
      end
      evaluator.requests_for.each do |resource, quantity|
        event.requests.create({
          element: resource.element,
          quantity: quantity
        })
      end
    end
  end

  factory :note do
    association :parent, factory: :event
    contents { "Some random text in a note" }
  end

  factory :resourcegrouppersona do
  end

  factory :resourcegroup do
    sequence(:name) { |n| "Resource group #{n}" }
    era
    starts_on { Date.today }
    association :persona, factory: :resourcegrouppersona
  end

  factory :user_form do
    sequence(:name) { |n| "User form #{n}" }
  end

  factory :commitment do
    event
    element
  end

  factory :user_form_response do
    user_form
    association :parent, factory: :commitment
  end

  factory :comment do
    user
    association :parent, factory: :user_form_response
    body { "Hello there - I'm a comment" }
  end

  factory :request do
    element
    event
    quantity { 1 }
  end

  factory :user_file do
    association :owner, factory: :user
    file_info { DummyFileInfo.new }
  end

  factory :rota_template_type do
    sequence(:name) { |n| "Rota template type #{n}" }
  end

  factory :rota_template do
    transient do
      with_slots { true }
      slots {
        [
          ["08:30", "09:00"],         # Preparation
          ["09:00", "09:20"],         # Assembly
          ["09:25", "10:15"],         # 1
          ["10:20", "11:10"],         # 2
          ["11:10", "11:30"],         # Break
          ["11:30", "12:20"],         # 3
          ["12:25", "13:15"],         # 4
          ["13:15", "14:00"],         # Lunch
          ["14:00", "14:45"],         # 5
          ["14:50", "15:35"],         # 6
          ["15:40", "16:30"],         # 7
          ["16:30", "17:00"]          # For really long exams
        ]
      }

    end
    trait :no_slots do
      with_slots { false }
    end

    sequence(:name) { |n| "Rota template #{n}" }
    rota_template_type
    after(:create) do |rota_template, evaluator|
      if evaluator.with_slots
        #
        #  We can't add rota slots until after it's been created.
        #
        evaluator.slots.each do |slot|
          rota_template.rota_slots.create({
            starts_at: slot[0],
            ends_at:   slot[1],
            days: [true, true, true, true, true, true, true]
          })
        end
      end
    end
  end

  factory :rota_slot do
    rota_template
    starts_at { Tod::TimeOfDay.parse("09:00") }
    ends_at   { Tod::TimeOfDay.parse("10:00") }
  end

  factory :exam_cycle do
    sequence(:name) { |n| "Exam cycle #{n}" }
    starts_on { Date.today }
    ends_on { Date.tomorrow }
    association :default_rota_template, factory: :rota_template
    default_group_element { create(:group).element }
  end

  factory :journal do
    event
  end

  factory :journal_entry do
    journal
    user
    element
  end

  factory :promptnote do
    element
  end

  factory :event_collection do
    era { Setting.current_era }
    repetition_start_date { Date.today }
    repetition_end_date   { Date.today + 1.month }
  end

  factory :membership do
    group
    element
    starts_on { Date.today }
    inverse { false }
  end

  factory :proto_event do
    sequence(:body) { |n| "Proto event #{n}" }
    association :generator, factory: :exam_cycle
    eventcategory
    eventsource
    starts_on { Date.today }
    ends_on { Date.tomorrow }
    location
    num_staff { "2" }
  end

  factory :proto_commitment do
    #
    #  ProtoCommitments need to be unique between event and element -
    #  you can't have two with the same event and element.
    #
    #  For this reason, even if we build() a proto_commitment, force
    #  automatic associations to be create()ed.
    #
    association :proto_event, factory: :proto_event, strategy: :create
    element
  end

  factory :proto_request do
    proto_event
    element
    quantity { 1 }
  end

  factory :freefinder do
    association :owner, factory: :user
    ft_start_date { Date.today }
    ft_num_days { 14 }
  end

  factory :itemreport do
    #
    #  I would normally have here just:
    #
    #    concern
    #
    #  but Rails defines a method of this name.
    #
    #  You can also write:
    #
    #    add_attribute(:concern) { ...block of code... }
    #
    #  to avoid this kind of name clash.
    #
    association :concern, factory: :concern
  end
end

