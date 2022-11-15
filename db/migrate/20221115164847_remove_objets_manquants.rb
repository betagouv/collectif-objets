class RemoveObjetsManquants < ActiveRecord::Migration[7.0]
  def up
    refs = get_palissy_refs_manquant
    puts "#{refs.count} REF d'objets manquants dans POP"
    objets_manquants = Objet.where(palissy_REF: refs)
    puts "#{objets_manquants.count}/#{refs.count} sont presents dans la db de CO"
    objets_without_recensements = objets_manquants.where.missing(:recensements)
    puts "#{objets_without_recensements.count}/#{objets_manquants.count} peuvent etre supprimés (les autres ont des recensements existants)"
    objets_without_recensements.delete_all
  end

  def down
  end

  private

  def get_palissy_refs_manquant
    refs = []
    url = first_url
    while url
      parsed = fetch_and_parse(url)
      refs += parsed["rows"].pluck("REF")
      url = parsed["next_url"]
    end
    refs
  end

  def first_url
    api_url = "https://collectif-objets-datasette.fly.dev/collectif-objets/palissy.json"
    params = {
      _size: "1000",
      _shape: "objects",
      _nofacet: "1",
      _sort: "rowid",
      _col: %w[REF],
      MANQUANT__in: "volé, manquant"
    }
    "#{api_url}?#{URI.encode_www_form(params)}"
  end

  def fetch_and_parse(url)
    res = Net::HTTP.get_response(URI.parse(url))
    raise "received #{res.code} on #{url}" unless res.code.starts_with?("2")

    parsed = JSON.parse(res.body)
    puts "request took #{parsed['query_ms'].round} ms"
    parsed
  end
end
