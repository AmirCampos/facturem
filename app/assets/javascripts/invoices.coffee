# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#btn_clear_filter").click ->
    $("#ed_filter_text").val("")
    $("#xb_signed_filter").attr("checked",null)
    $("#xb_presented_filter").attr("checked",null)

    window.location.href = '/invoices'
