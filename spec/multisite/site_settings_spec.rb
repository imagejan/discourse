require 'rails_helper'

RSpec.describe 'Multisite SiteSettings' do
  let(:conn) { RailsMultisite::ConnectionManagement }

  before do
    @original_provider = SiteSetting.provider
    SiteSetting.provider = SiteSettings::DbProvider.new(SiteSetting)
    conn.config_filename = "spec/fixtures/multisite/two_dbs.yml"
    conn.load_settings!
  end

  after do
    ['default', 'second'].each do |db|
      conn.with_connection(db) { SiteSetting.destroy_all }
    end

    conn.clear_settings!

    [:@@db_spec_cache, :@@host_spec_cache, :@@default_spec].each do |class_variable|
      conn.remove_class_variable(class_variable)
    end

    SiteSetting.provider = @original_provider
  end

  describe '#default_locale' do
    it 'should return the right locale' do
      conn.with_connection('default') do
        expect(SiteSetting.default_locale).to eq('en')
      end

      conn.with_connection('second') do
        SiteSetting.default_locale = 'zh_TW'

        expect(SiteSetting.default_locale).to eq('zh_TW')
      end

      conn.with_connection('default') do
        expect(SiteSetting.default_locale).to eq('en')

        SiteSetting.default_locale = 'ja'

        expect(SiteSetting.default_locale).to eq('ja')
      end

      conn.with_connection('second') do
        expect(SiteSetting.default_locale).to eq('zh_TW')
      end
    end
  end
end
