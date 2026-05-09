FactoryBot.define do
  factory :institution_role do
    user
    role     { :school_admin }
    district { nil }
    school   { nil }
    active   { true }

    trait :district_admin do
      role     { :district_admin }
      district { association :district }
      school   { nil }
    end

    trait :school_admin do
      role   { :school_admin }
      school { association :school }
    end

    trait :athletic_director do
      role   { :athletic_director }
      school { association :school }
    end
  end
end
