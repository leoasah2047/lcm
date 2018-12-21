# This object allow printing the general ledger
class BalanceSheetPrinter
  include PdfPrinter

  def initialize(options)
    @document_nature = Nomen::DocumentNature.find(options[:document_nature])
    @key             = options[:key]
    @template_path   = find_open_document_template(options[:document_nature])
    @params          = options[:params]
    @financial_year  = options[:financial_year]
  end

  def compute_dataset
    dataset = []
    document_scope = :balance_sheet
    current_compute = AccountancyComputation.new(@financial_year)
    previous_compute = AccountancyComputation.new(@financial_year.previous)
    ## ACTIF
    actif = []

    # unsubcribed_capital - 109
    g1 = HashWithIndifferentAccess.new
    g1[:group_name] = :unsubcribed_capital.tl
    g1[:items] = []
    items = [:unsubcribed_capital]
    items.each do |item|
      i = HashWithIndifferentAccess.new
      i[:name] = item.to_s.tl
      i[:current_raw_value] = current_compute.sum_entry_items_by_line(document_scope, item)
      i[:current_variations] = ''
      i[:current_net_value] = current_compute.sum_entry_items_by_line(document_scope, item)
      i[:previous_raw_value] = previous_compute.sum_entry_items_by_line(document_scope, item)
      i[:previous_variations] = ''
      i[:previous_net_value] = previous_compute.sum_entry_items_by_line(document_scope, item)
      g1[:items] << i
      # puts g1.inspect.yellow
    end
    g1[:sum_name] = ""
    g1[:current_raw_total] = ''
    g1[:current_variations_total] = ''
    g1[:current_net_total] = ''
    g1[:previous_raw_total] = ''
    g1[:previous_variations_total] = ''
    g1[:previous_net_total] = ''
    actif << g1

    # incorporeal_assets - 201...
    g2 = HashWithIndifferentAccess.new
    g2[:group_name] = :incorporeal_assets.tl
    g2[:items] = []
    items = [:incorporeal_assets_creation_costs, :incorporeal_assets_others, :incorporeal_assets_advances]
    items.each do |item|
      i = HashWithIndifferentAccess.new
      i[:name] = item.to_s.tl
      i[:current_raw_value] = current_compute.sum_entry_items_by_line(document_scope, item)
      i[:current_variations] = current_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:current_net_value] = (i[:current_raw_value].to_d - i[:current_variations].to_d).round(2)
      i[:previous_raw_value] = previous_compute.sum_entry_items_by_line(document_scope, item)
      i[:previous_variations] = previous_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:previous_net_value] = (i[:previous_raw_value].to_d - i[:previous_variations].to_d).round(2)
      g2[:items] << i
      # puts g2.inspect.yellow
    end
    g2[:sum_name] = ''
    g2[:current_raw_total] = current_compute.sum_entry_items_by_line(document_scope, :incorporeal_assets_total)
    g2[:current_variations_total] = current_compute.sum_entry_items_by_line(document_scope, :incorporeal_assets_total_depreciations)
    g2[:current_net_total] = (g2[:current_raw_total].to_d - g2[:current_variations_total].to_d).round(2)
    g2[:previous_raw_total] = previous_compute.sum_entry_items_by_line(document_scope, :incorporeal_assets_total)
    g2[:previous_variations_total] = previous_compute.sum_entry_items_by_line(document_scope, :incorporeal_assets_total_depreciations)
    g2[:previous_net_total] = (g2[:previous_raw_total].to_d - g2[:previous_variations_total].to_d).round(2)
    actif << g2

    # corporeal_assets - 211...
    g3 = HashWithIndifferentAccess.new
    g3[:group_name] = :corporeal_assets.tl
    g3[:items] = []
    items = [:corporeal_assets_land_parcels, :corporeal_assets_settlements,
             :corporeal_assets_enhancement, :corporeal_assets_buildings,
             :corporeal_assets_equipments, :corporeal_assets_others,
             :corporeal_assets_in_progress, :corporeal_assets_advances]
    items.each do |item|
      i = HashWithIndifferentAccess.new
      i[:name] = item.to_s.tl
      i[:current_raw_value] = current_compute.sum_entry_items_by_line(document_scope, item)
      i[:current_variations] = current_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:current_net_value] = (i[:current_raw_value].to_d - i[:current_variations].to_d).round(2)
      i[:previous_raw_value] = previous_compute.sum_entry_items_by_line(document_scope, item)
      i[:previous_variations] = previous_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:previous_net_value] = (i[:previous_raw_value].to_d - i[:previous_variations].to_d).round(2)
      g3[:items] << i
      # puts g3.inspect.yellow
    end
    g3[:sum_name] = ''
    g3[:current_raw_total] = current_compute.sum_entry_items_by_line(document_scope, :corporeal_assets_total)
    g3[:current_variations_total] = current_compute.sum_entry_items_by_line(document_scope, :corporeal_assets_total_depreciations)
    g3[:current_net_total] = (g3[:current_raw_total].to_d - g3[:current_variations_total].to_d).round(2)
    g3[:previous_raw_total] = previous_compute.sum_entry_items_by_line(document_scope, :corporeal_assets_total)
    g3[:previous_variations_total] = previous_compute.sum_entry_items_by_line(document_scope, :corporeal_assets_total_depreciations)
    g3[:previous_net_total] = (g3[:previous_raw_total].to_d - g3[:previous_variations_total].to_d).round(2)
    actif << g3

    # alive corporeal_assets - 211...
    g4 = HashWithIndifferentAccess.new
    g4[:group_name] = :alive_corporeal_assets.tl
    g4[:items] = []
    items = [:alive_corporeal_assets_adult_animals, :alive_corporeal_assets_young_animals,
             :alive_corporeal_assets_service_animals, :alive_corporeal_assets_perennial_plants,
             :alive_corporeal_assets_others, :alive_corporeal_assets_in_progress,
             :alive_corporeal_assets_advances]
    items.each do |item|
      i = HashWithIndifferentAccess.new
      i[:name] = item.to_s.tl
      i[:current_raw_value] = current_compute.sum_entry_items_by_line(document_scope, item)
      i[:current_variations] = current_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:current_net_value] = (i[:current_raw_value].to_d - i[:current_variations].to_d).round(2)
      i[:previous_raw_value] = previous_compute.sum_entry_items_by_line(document_scope, item)
      i[:previous_variations] = previous_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:previous_net_value] = (i[:previous_raw_value].to_d - i[:previous_variations].to_d).round(2)
      g4[:items] << i
      # puts g3.inspect.yellow
    end
    g4[:sum_name] = ''
    g4[:current_raw_total] = current_compute.sum_entry_items_by_line(document_scope, :alive_corporeal_assets_total)
    g4[:current_variations_total] = current_compute.sum_entry_items_by_line(document_scope, :alive_corporeal_assets_total_depreciations)
    g4[:current_net_total] = (g4[:current_raw_total].to_d - g4[:current_variations_total].to_d).round(2)
    g4[:previous_raw_total] = previous_compute.sum_entry_items_by_line(document_scope, :alive_corporeal_assets_total)
    g4[:previous_variations_total] = previous_compute.sum_entry_items_by_line(document_scope, :alive_corporeal_assets_total_depreciations)
    g4[:previous_net_total] = (g4[:previous_raw_total].to_d - g4[:previous_variations_total].to_d).round(2)
    actif << g4

    # financial_assets - 261...
    g5 = HashWithIndifferentAccess.new
    g5[:group_name] = :financial_assets.tl
    g5[:items] = []
    items = [:financial_assets_participations, :financial_assets_participations_debts,
             :financial_assets_others]
    items.each do |item|
      i = HashWithIndifferentAccess.new
      i[:name] = item.to_s.tl
      i[:current_raw_value] = current_compute.sum_entry_items_by_line(document_scope, item)
      i[:current_variations] = current_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:current_net_value] = (i[:current_raw_value].to_d - i[:current_variations].to_d).round(2)
      i[:previous_raw_value] = previous_compute.sum_entry_items_by_line(document_scope, item)
      i[:previous_variations] = previous_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:previous_net_value] = (i[:previous_raw_value].to_d - i[:previous_variations].to_d).round(2)
      g5[:items] << i
      # puts g5.inspect.yellow
    end
    g5[:sum_name] = ''
    g5[:current_raw_total] = current_compute.sum_entry_items_by_line(document_scope, :financial_assets_total)
    g5[:current_variations_total] = current_compute.sum_entry_items_by_line(document_scope, :financial_assets_total_depreciations)
    g5[:current_net_total] = (g5[:current_raw_total].to_d - g5[:current_variations_total].to_d).round(2)
    g5[:previous_raw_total] = previous_compute.sum_entry_items_by_line(document_scope, :financial_assets_total)
    g5[:previous_variations_total] = previous_compute.sum_entry_items_by_line(document_scope, :financial_assets_total_depreciations)
    g5[:previous_net_total] = (g5[:previous_raw_total].to_d - g5[:previous_variations_total].to_d).round(2)
    actif << g5

    # long_cycle_alive_products - 31...
    g6 = HashWithIndifferentAccess.new
    g6[:group_name] = :long_cycle_alive_products.tl
    g6[:items] = []
    items = [:long_cycle_alive_products_animals, :long_cycle_alive_products_plant_advance,
             :long_cycle_alive_products_plant_in_ground, :long_cycle_alive_products_wine,
             :long_cycle_alive_products_others]
    items.each do |item|
      i = HashWithIndifferentAccess.new
      i[:name] = item.to_s.tl
      i[:current_raw_value] = current_compute.sum_entry_items_by_line(document_scope, item)
      i[:current_variations] = current_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:current_net_value] = (i[:current_raw_value].to_d - i[:current_variations].to_d).round(2)
      i[:previous_raw_value] = previous_compute.sum_entry_items_by_line(document_scope, item)
      i[:previous_variations] = previous_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:previous_net_value] = (i[:previous_raw_value].to_d - i[:previous_variations].to_d).round(2)
      g6[:items] << i
      # puts g5.inspect.yellow
    end
    g6[:sum_name] = ''
    g6[:current_raw_total] = current_compute.sum_entry_items_by_line(document_scope, :long_cycle_alive_products_total)
    g6[:current_variations_total] = current_compute.sum_entry_items_by_line(document_scope, :long_cycle_alive_products_total_depreciations)
    g6[:current_net_total] = (g6[:current_raw_total].to_d - g6[:current_variations_total].to_d).round(2)
    g6[:previous_raw_total] = previous_compute.sum_entry_items_by_line(document_scope, :long_cycle_alive_products_total)
    g6[:previous_variations_total] = previous_compute.sum_entry_items_by_line(document_scope, :long_cycle_alive_products_total_depreciations)
    g6[:previous_net_total] = (g6[:previous_raw_total].to_d - g6[:previous_variations_total].to_d).round(2)
    actif << g6

    # short_cycle_alive_products - 32...
    g7 = HashWithIndifferentAccess.new
    g7[:group_name] = :short_cycle_alive_products.tl
    g7[:items] = []
    items = [:short_cycle_alive_products_animals, :short_cycle_alive_products_plant_advance,
             :short_cycle_alive_products_plant_in_ground, :short_cycle_alive_products_others]
    items.each do |item|
      i = HashWithIndifferentAccess.new
      i[:name] = item.to_s.tl
      i[:current_raw_value] = current_compute.sum_entry_items_by_line(document_scope, item)
      i[:current_variations] = current_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:current_net_value] = (i[:current_raw_value].to_d - i[:current_variations].to_d).round(2)
      i[:previous_raw_value] = previous_compute.sum_entry_items_by_line(document_scope, item)
      i[:previous_variations] = previous_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:previous_net_value] = (i[:previous_raw_value].to_d - i[:previous_variations].to_d).round(2)
      g7[:items] << i
      # puts g5.inspect.yellow
    end
    g7[:sum_name] = ''
    g7[:current_raw_total] = current_compute.sum_entry_items_by_line(document_scope, :short_cycle_alive_products_total)
    g7[:current_variations_total] = current_compute.sum_entry_items_by_line(document_scope, :short_cycle_alive_products_total_depreciations)
    g7[:current_net_total] = (g7[:current_raw_total].to_d - g7[:current_variations_total].to_d).round(2)
    g7[:previous_raw_total] = previous_compute.sum_entry_items_by_line(document_scope, :short_cycle_alive_products_total)
    g7[:previous_variations_total] = previous_compute.sum_entry_items_by_line(document_scope, :short_cycle_alive_products_total_depreciations)
    g7[:previous_net_total] = (g7[:previous_raw_total].to_d - g7[:previous_variations_total].to_d).round(2)
    actif << g7

    # Stock - 30...
    g8 = HashWithIndifferentAccess.new
    g8[:group_name] = :stocks.tl
    g8[:items] = []
    items = [:stocks_supply, :stocks_end_products, :stocks_others_products]
    items.each do |item|
      i = HashWithIndifferentAccess.new
      i[:name] = item.to_s.tl
      i[:current_raw_value] = current_compute.sum_entry_items_by_line(document_scope, item)
      i[:current_variations] = current_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:current_net_value] = (i[:current_raw_value].to_d - i[:current_variations].to_d).round(2)
      i[:previous_raw_value] = previous_compute.sum_entry_items_by_line(document_scope, item)
      i[:previous_variations] = previous_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:previous_net_value] = (i[:previous_raw_value].to_d - i[:previous_variations].to_d).round(2)
      g8[:items] << i
      # puts g5.inspect.yellow
    end
    g8[:sum_name] = ''
    g8[:current_raw_total] = current_compute.sum_entry_items_by_line(document_scope, :stocks_total)
    g8[:current_variations_total] = current_compute.sum_entry_items_by_line(document_scope, :stocks_total_depreciations)
    g8[:current_net_total] = (g8[:current_raw_total].to_d - g8[:current_variations_total].to_d).round(2)
    g8[:previous_raw_total] = previous_compute.sum_entry_items_by_line(document_scope, :stocks_total)
    g8[:previous_variations_total] = previous_compute.sum_entry_items_by_line(document_scope, :stocks_total_depreciations)
    g8[:previous_net_total] = (g8[:previous_raw_total].to_d - g8[:previous_variations_total].to_d).round(2)
    actif << g8

    # Others - 40...
    g9 = HashWithIndifferentAccess.new
    g9[:group_name] = :entities.tl
    g9[:items] = []
    items = [:entities_advance_giveables, :entities_client_receivables,
             :entities_others_clients, :entities_state_receivables,
             :entities_associate_receivables, :entities_other_receivables,
             :entities_investment_security, :entities_reserve,
             :entities_advance_charges, :entities_assets_gaps]
    items.each do |item|
      i = HashWithIndifferentAccess.new
      i[:name] = item.to_s.tl
      i[:current_raw_value] = current_compute.sum_entry_items_by_line(document_scope, item)
      i[:current_variations] = current_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:current_net_value] = (i[:current_raw_value].to_d - i[:current_variations].to_d).round(2)
      i[:previous_raw_value] = previous_compute.sum_entry_items_by_line(document_scope, item)
      i[:previous_variations] = previous_compute.sum_entry_items_by_line(document_scope, (item.to_s + "_depreciations").to_sym)
      i[:previous_net_value] = (i[:previous_raw_value].to_d - i[:previous_variations].to_d).round(2)
      g9[:items] << i
      # puts g5.inspect.yellow
    end
    g9[:sum_name] = ''
    g9[:current_raw_total] = current_compute.sum_entry_items_by_line(document_scope, :stocks_total)
    g9[:current_variations_total] = current_compute.sum_entry_items_by_line(document_scope, :stocks_total_depreciations)
    g9[:current_net_total] = (g9[:current_raw_total].to_d - g9[:current_variations_total].to_d).round(2)
    g9[:previous_raw_total] = previous_compute.sum_entry_items_by_line(document_scope, :stocks_total)
    g9[:previous_variations_total] = previous_compute.sum_entry_items_by_line(document_scope, :stocks_total_depreciations)
    g9[:previous_net_total] = (g9[:previous_raw_total].to_d - g9[:previous_variations_total].to_d).round(2)
    actif << g9

    dataset << actif

    passif = []

    # Capitals - 1...
    h = HashWithIndifferentAccess.new
    h[:group_name] = :capitals.tl
    h[:items] = []
    items = [:capitals_values, :capitals_emissions_and_reevaluation_gaps,
             :capitals_liability_reserves, :capitals_anew_reports,
             :capitals_profit_or_loss, :capitals_investment_subsidies,
             :capitals_derogatory_depreciations, :capitals_mandatory_provisions,
             :capitals_risk_and_charges_provisions]
    items.each do |item|
      i = HashWithIndifferentAccess.new
      i[:name] = item.to_s.tl
      i[:current_raw_value] = current_compute.sum_entry_items_by_line(document_scope, item)
      i[:previous_raw_value] = previous_compute.sum_entry_items_by_line(document_scope, item)
      h[:items] << i
      # puts g5.inspect.yellow
    end
    h[:sum_name] = ''
    h[:current_raw_total] = current_compute.sum_entry_items_by_line(document_scope, :stocks_total)
    h[:previous_raw_total] = previous_compute.sum_entry_items_by_line(document_scope, :stocks_total)
    passif << h



    dataset << passif

    dataset.compact
  end

  def run_pdf
    dataset = compute_dataset

    report = generate_document(@document_nature, @key, @template_path) do |r|

      # build header
      e = Entity.of_company
      company_name = e.full_name
      company_address = e.default_mail_address&.coordinate

      # build filters
      data_filters = []

      # build started and stopped
      started_on = @financial_year.started_on
      stopped_on = @financial_year.stopped_on

      r.add_field 'COMPANY_ADDRESS', company_address
      r.add_field 'DOCUMENT_NAME', @document_nature.human_name
      r.add_field 'FILE_NAME', @key
      r.add_field 'PERIOD', I18n.translate('labels.from_to_date', from: started_on.l, to: stopped_on.l)
      r.add_field 'DATE', Date.today.l
      r.add_field 'STARTED_ON', started_on.to_date.l
      r.add_field 'N', stopped_on.to_date.l
      r.add_field 'N_1', @financial_year.previous.stopped_on.to_date.l
      r.add_field 'PRINTED_AT', Time.zone.now.l(format: '%d/%m/%Y %T')
      r.add_field 'DATA_FILTERS', data_filters * ' | '

      r.add_section('Section1', dataset[0]) do |s|
        s.add_field(:group_name, :group_name)
        s.add_table('Tableau1', :items, header: true) do |t|
          t.add_column(:name) { |item| item[:name] }
          t.add_column(:current_raw_value) { |item| item[:current_raw_value] }
          t.add_column(:current_variations) { |item| item[:current_variations] }
          t.add_column(:current_net_value) { |item| item[:current_net_value] }
          t.add_column(:previous_raw_value) { |item| item[:previous_raw_value] }
          t.add_column(:previous_variations) { |item| item[:previous_variations] }
          t.add_column(:previous_net_value) { |item| item[:previous_net_value] }
        end
        s.add_field(:sum_name, :sum_name)
        s.add_field(:c_r_total, :current_raw_total)
        s.add_field(:c_v_total, :current_variations_total)
        s.add_field(:c_n_total, :current_net_total)
        s.add_field(:p_r_total, :previous_raw_total)
        s.add_field(:p_v_total, :previous_variations_total)
        s.add_field(:p_n_total, :previous_net_total)

      end

      r.add_section('Section2', dataset[1]) do |s|
        s.add_field(:group_name, :group_name)
        s.add_table('Tableau5', :items, header: true) do |t|
          t.add_column(:name) { |item| item[:name] }
          t.add_column(:current_raw_value) { |item| item[:current_raw_value] }
          t.add_column(:previous_raw_value) { |item| item[:previous_raw_value] }
        end
        s.add_field(:sum_name, :sum_name)
        s.add_field(:c_r_total, :current_raw_total)
        s.add_field(:p_r_total, :previous_raw_total)

      end

    end
    report.file.path
  end

end
