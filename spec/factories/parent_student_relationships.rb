FactoryBot.define do
  factory :parent_student_relationship do
    parent  { association :user }
    student { association :user }
    active  { true }
  end
end
