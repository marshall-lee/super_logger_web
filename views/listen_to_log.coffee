originalTitle = document.title
title = originalTitle
isFocused = true
nUnread = 0

$ ->
  $(window)
    .focus ->
      isFocused = true
      nUnread = 0
      document.title = originalTitle
    .blur ->
      isFocused = false

  setTitleWithUndread = ->
    document.title = "[#{nUnread}] | #{originalTitle}"

  setInterval (->
      unless isFocused
        if document.title == originalTitle && nUnread > 0
          setTitleWithUndread()
        else
          document.title = originalTitle
    ), 500

  FayeClient.subscribe FAYE_LOG_CHANNEL, (message) ->
    $('table.log').append(message.row.html)
    unless isFocused
      nUnread += 1
      setTitleWithUndread()
