class AccountTemplateShowSerializer < ApplicationSerializer
  attributes :currency

  has_many :reports, each_serializer: ReportSerializer do
    object.reports
  end
end
