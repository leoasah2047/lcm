class GainAndLossFixedAssetPrinter < GeneralFixedAssetPrinter
  include PdfPrinter

  def initialize(options)
    @document_nature = Nomen::DocumentNature.find(options[:document_nature])
    @key             = options[:key]
    @template_path   = find_open_document_template("#{options[:nature]}_#{options[:document_nature]}")
    @period          = options[:period]
    @nature          = options[:nature]
  end

  def compute_dataset
    to = @period == 'all' ? FinancialYear.current.stopped_on : Date.parse(@period.split('_').last)
    fixed_assets = FixedAsset.sold_or_scrapped.start_before(to)

    assets = fixed_assets.map do |fixed_asset|
      asset = {
        number: fixed_asset.number,
        label: fixed_asset.name,
        purchased_on: fixed_asset.purchased_on,
        ceded_on: fixed_asset.sold_on,
        purchase_amount: fixed_asset.purchase_amount,
        depreciated_amount: fixed_asset.depreciated_amount,
        residual_value: fixed_asset.purchase_amount - fixed_asset.depreciated_amount,
        selling_amount: fixed_asset.selling_amount,
        gain_and_loss: fixed_asset.selling_amount - (fixed_asset.purchase_amount - fixed_asset.depreciated_amount)
      }
    end

    totals = {
      total_residual_value: assets.map { |asset| asset[:residual_value] }.sum,
      total_sold_amount: assets.map { |asset| asset[:selling_amount] }.sum,
      total_gain_and_loss: assets.map { |asset| asset[:gain_and_loss] }.sum
    }

    dataset = [ { assets: assets }, totals ]
  end

  def run_pdf
    dataset = compute_dataset
    report = generate_document(@document_nature, @key, @template_path) do |r|

      e = Entity.of_company
      company_name = e.full_name
      company_address = e.default_mail_address&.coordinate

      stopped_on = @period == 'all' ? FinancialYear.current.stopped_on : Date.parse(@period.split('_').last)

      r.add_field 'COMPANY_ADDRESS', company_address
      r.add_field 'DOCUMENT_NAME', I18n.translate("labels.#{@nature}_fixed_assets", to: stopped_on.l)
      r.add_field 'FILE_NAME', @key
      r.add_field 'STOPPED_ON', stopped_on.to_date.l
      r.add_field 'PRINTED_AT', Time.zone.now.l(format: '%d/%m/%Y %T')
      r.add_field 'TOTAL_RESIDUAL_VALUE', dataset.last[:total_residual_value]
      r.add_field 'TOTAL_SOLD_AMOUNT', dataset.last[:total_sold_amount]
      r.add_field 'TOTAL_GAIN_AND_LOSS', dataset.last[:total_gain_and_loss]

      r.add_section('Section1', dataset[0...-1]) do |s|

        s.add_table('Table2', :assets) do |t|
          t.add_column(:fixed_asset_number) { |asset| asset[:number] }
          t.add_column(:label) { |asset| asset[:label] }
          t.add_column(:purchased_on) { |asset| asset[:purchased_on].strftime('%d/%m/%Y') }
          t.add_column(:ceded_on) { |asset| asset[:ceded_on].strftime('%d/%m/%Y') }
          t.add_column(:purchase_amount) { |asset| asset[:purchase_amount] }
          t.add_column(:depreciated_amount) { |asset| asset[:depreciated_amount] }
          t.add_column(:residual_value) { |asset| asset[:residual_value] }
          t.add_column(:selling_amount) { |asset| asset[:selling_amount] }
          t.add_column(:gain_and_loss) { |asset| asset[:gain_and_loss] }
        end
      end
    end
    report.file.path
  end
end
