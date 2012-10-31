namespace :atmtag do
  desc "Load banks from YAML"
  task "load" => :environment do
    # bbs == banks by state
    bbs = YAML::load_file( File.join( Rails.root, "config", "banks.yaml" ) )
    bbs.keys.each do |state|
      bbs[state].each do |bank|
        Bank.create name: bank, state: state, country: "USA"
      end
    end
  end


  desc "Scrape banks from Wikipedia"
  task "scrape" => :environment do
    
  end
end
