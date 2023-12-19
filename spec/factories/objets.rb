# frozen_string_literal: true

FactoryBot.define do
  factory :objet do
    sequence(:palissy_REF) { |n| "PM#{n + 51_001_252}" }
    memoire_REF { "AP80L043503" }
    palissy_TICO { "La Sainte-Famille" }
    palissy_CATE { "Peinture" }
    palissy_SCLE { "16e siècle" }
    palissy_DOSS { "Dossier individuel" }
    palissy_EDIF { "Eglise Notre-Dame-en-Vaux" }
    palissy_EMPL { "dans la nef droite" }
    palissy_DPRO { "2007/01/29 : classé au titre objet" }
    palissy_PROT { "classé au titre objet" }

    association :commune
    association :edifice

    trait :without_image do
      # do nothing
    end

    trait :with_recensement do
      recensements { [association(:recensement)] }
    end

    trait :with_recensement_with_photos_mocked do
      transient do
        recensement_photos_count { 1 }
        recensement_photos_start_number { 1 }
      end
      recensements do
        [
          association(
            :recensement, :with_photos_mocked,
            photos_start_number: recensement_photos_start_number,
            photos_count: recensement_photos_count
          )
        ]
      end
    end

    trait :with_recensement_without_photo do
      recensements { [association(:recensement, :without_photo)] }
    end

    trait :with_palissy_photo do
      transient do
        palissy_photo_number { 1 }
      end
      palissy_photos do
        [
          {
            "url" => "/demo/objets/objet#{palissy_photo_number}.jpg",
            "credit" => "© Médiathèque Paris",
            "name" => "Vase bleu"
          }
        ]
      end
    end

    trait :with_palissy_photos do
      palissy_photos do
        (1..3).map do |i|
          {
            "url" => "/demo/objets/objet#{i}.jpg",
            "credit" => "© Médiathèque Paris",
            "name" => "Vase bleu"
          }
        end
      end
    end

    factory :objet_en_peril do
      recensements { [association(:recensement, :en_peril)] }
    end

    trait :disparu do
      recensements { [association(:recensement, :disparu)] }
    end
  end
end
