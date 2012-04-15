module Instabil
  class SummaryPresenter
    class << self
      attr_reader :steps

      def step name, options={}
        @steps ||= []
        @steps << options.merge(name: name)
      end
    end

    attr_reader :collection

    def initialize(collection)
      @collection = collection
    end

    step :signup, title: 'Angemeldet', check: lambda{|p| p.active? }
    step :page_assigned, title: 'Bericht <span>eingetragen</span>', check: lambda{|p| p.page.present? }
    step :page_corrected, title: 'Bericht <span>korrigiert</span>'
    step :meta, title: 'Metadaten'
    step :tags, title: 'mind. 5 Tags', check: lambda{|p| p.tags.length > 4 }
    step :photo, title: 'Foto', check: lambda{|p| p.avatar.present? }
    step :final, title: 'Endabnahme'

    def steps
      self.class.steps
    end

    def data_point_count
      @collection.length * steps.length
    end

    def run
      totals = [0] * steps.length
      results = @collection.map do |record|
        result = steps.map{ |step| (step[:check] || lambda {|r| false }).call(record) }
        result.each_with_index do |step_result, i|
          totals[i] += (step_result == true ? 1 : 0)
        end
        [record, result]
      end

      [results, totals]
    end
  end
end