((E, $) ->
  'use strict'

  $(document).ready ->
    $('input[data-warn-if-checked]').behave 'load', ->
      $('input[data-warn-if-checked]').each ->
        $input = $(this)

        messageText     = $input.data('warn-if-checked')
        messageSelector = $input.data('warn-in')
        $message        = $input.formScopedSelect(messageSelector)

        # Fallback if messageSelector doesn't match anything in scope
        $defaultMessage = $('<span class="warn-message"></span>')
        if $message.length is 0
          $input.formScope().append($defaultMessage)
          $message = $defaultMessage

        showOrHideMessage = (input) ->
          if $input.prop('checked')
            $message.show()
          else
            $message.hide()

        $message.html(messageText) if $message.is(':empty')

        showOrHideMessage($input) # Initial display
        $input.click showOrHideMessage # Update on input change


    $('h2[data-warn-if-checked]').behave 'load', ->
      $('h2[data-warn-if-checked]').each ->
        h2 = $(this)
        h2.html(h2.data('warn-if-checked'))
        if $('input[data-warn-if-checked]:checked').length >= 1
          h2.show()
        $('input[data-warn-if-checked]').click ->
          if $('input[data-warn-if-checked]:checked:visible').length >= 1
            h2.show()
          else
            h2.hide()

    $('table.list').on 'cocoon:after-insert', (event, $insertedItem) ->
      $('*[data-iceberg]').on "iceberg:inserted", ->
        that = $(this)
        $(this).find('*[data-association]').each (i, cocoonBtn) ->
          node = $(cocoonBtn).data('association-insertion-node')
          storageContainer = $(node).parent()
          storageContainer.on 'cocoon:after-insert cocoon:after-remove', ->
            E.toggleValidateButton(that)
            E.setStorageUnitName(that)

      if $insertedItem && $insertedItem.hasClass('storing-fields')
        unitName = $insertedItem.closest('.item-block__storing').find('.storage-unit-name').first().text()
        $insertedItem.find('.storage-unit-name').text(unitName)



    $('.new_reception, .edit_reception').on 'change', '#reception_reconciliation_state', (event) ->
      checked = $(event.target).is(':checked')

      if checked
        $(event.target).val('accepted')
      else
        $(event.target).val('to_reconciliate')





  E.Receptions =
    fillStocksCounters: (form) ->
      $currentForm = $(form)
      variantId = $currentForm.find('[data-product-of-delivery-item]').next('.selector-value').val()

      return unless variantId? && !(variantId == '')

      $.ajax
        url: "/backend/product_nature_variants/#{variantId}/detail",
        success: (data, status, request) ->
          $currentForm.find('.storing__footer .merchandise-total-current-stock .stock-value').text(parseFloat(data.stock).toFixed(2))
          $currentForm.find('.storing__footer .merchandise-total-current-stock .stock-unit').text(data.unit.name)

          reducer = (acc, val) ->
                      parseFloat(acc) + parseFloat(val)

          quantity = $('.storing-quantity').map ->
            $(this).val() || 0
          .toArray()
          .reduce(reducer)

          newStock = parseFloat(data.stock) + parseFloat(quantity)
          $currentForm.find('.storing__footer .merchandise-total-stock-after-reception .stock-value').text(newStock.toFixed(2))
          $currentForm.find('.storing__footer .merchandise-total-stock-after-reception .stock-unit').text(data.unit.name)

      $currentForm.find('.nested-fields').each ->
        $storingItem = $(this)
        storageId = $storingItem.find('.parcel-item-storage').next('.selector-value').val()

        return unless storageId

        url =  "/backend/product_nature_variants/#{variantId}/storage_detail"
        $.ajax url,
          type: 'GET'
          dataType: 'JSON'
          data: { storage_id: storageId }

          success: (data, status, request) ->
            $storingItem.find('.merchandise-current-stock .stock-value').text(parseFloat(data.quantity).toFixed(2))
            $storingItem.find('.merchandise-current-stock .stock-unit').text(data.unit)

            quantity = $storingItem.find('.storing-quantity').val() || 0
            newStock = parseFloat(data.quantity) + parseFloat(quantity)
            $storingItem.find('.merchandise-stock-after-reception .stock-value').text(newStock.toFixed(2))
            $storingItem.find('.merchandise-stock-after-reception .stock-unit').text(data.unit)


  $(document).on 'selector:change', '.parcel-item-variant.selector-search', (event) ->
    E.Receptions.fillStocksCounters($(event.target).closest('.nested-item-form'))

  $(document).on 'keyup change', '.nested-fields .storing-quantifier .storing-quantity', (event) ->
    E.Receptions.fillStocksCounters($(event.target).closest('.nested-item-form'))

  $(document).on 'selector:change', '.parcel-item-storage.selector-search', (event) ->
    E.Receptions.fillStocksCounters($(event.target).closest('.nested-item-form'))

) ekylibre, jQuery
