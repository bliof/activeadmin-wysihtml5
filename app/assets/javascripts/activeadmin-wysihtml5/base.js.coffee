#= require activeadmin-wysihtml5/wysihtml5.min
#= require activeadmin-wysihtml5/parser_rules
#= require activeadmin-wysihtml5/jquery.paginate.min

(($) ->

  $.fn.modal = (options) ->
    $overlay = $("#lean_overlay")
    if $overlay.length == 0
      $overlay = $("<div/>").attr(id: 'modal-overlay').appendTo("body")

    @each ->
      $content = $(@).appendTo("body")
      $overlay.show()
      height = $content.outerHeight()
      width = $content.outerWidth()

      $content.css(
        display: 'block'
        position: 'fixed'
        zIndex: 1200
        left: '50%'
        top: 140
        marginLeft: - width * 0.5
      ).show()

      $content.on 'click', '[data-modal=close]', ->
        $overlay.hide()
        $content.hide().remove()

  $.fn.activeAdminWysihtml5 = (options) ->
    this.each ->
      $editor = $(this)
      return if $editor.data('activeadmin-wysihtml5')

      $editor.data('activeadmin-wysihtml5', true)

      $toolbar = $editor.find('.toolbar')
      $textarea = $editor.find('textarea')

      editor = new wysihtml5.Editor($textarea.attr('id'), {
        toolbar: $toolbar.attr('id'),
        stylesheets: "/assets/activeadmin-wysihtml5/wysiwyg.css",
        parserRules: wysihtml5ParserRules
      })

      $button = $toolbar.find('a[data-wysihtml5-command=createLink]').click ->
        $modal = $editor.find(".modal-link").clone()
        $field = $modal.find("input")
        $tab_contents = $modal.find("[data-tab]").hide()
        $tab_handles = $modal.find("[data-tab-handle]").click ->
          $tab_contents.hide()
          $tab_contents.filter($(@).attr("href")).show()
          $tab_handles.removeClass("active")
          $(@).addClass("active")
          false

        activeButton = $(this).hasClass("wysihtml5-command-active")
        if !activeButton
          $modal.modal()
          $tab_contents.find("[name=text]").val(editor.composer.selection.getText())
          $tab_handles.eq(0).click()

          $modal.find("[data-action=save]").click ->
            $content = $tab_contents.filter(":visible")
            el = switch $content.attr("id")
              when "modal-link-url"
                href: $content.find("[name=url]").val()
                text: $content.find("[name=text]").val()
                rel: $content.find("[name=rel]").val()
                title: $content.find("[name=title]").val()
                target: (if $content.find("[name=blank]").is(":checked") then "_blank" else "")
              when "modal-link-email"
                href: "mailto:" + $content.find("[name=email]").val()
                text: $content.find("[name=text]").val()
              when "modal-link-anchor"
                id: $content.find("[name=anchor]").val()
                text: $content.find("[name=text]").val()

            editor.currentView.element.focus()
            editor.composer.commands.exec("createLink", el)

          false
        else
          true

      $toolbar.find('a[data-wysihtml5-command=insertImage]').click ->
        $modal = $editor.find(".modal-image").clone()
        $url = $modal.find('[name=url]')
        selectedAsset = null

        $modal.find('[data-action=save]').click ->
          el = {
            src: $modal.find("[name=url]").val()
            class: $modal.find("[name=alignment]").val()
            alt: $modal.find("[name=alt]").val()
          }

          el['title'] = el['alt']

          if el['src']
            editor.currentView.element.focus()
            editor.composer.commands.exec("insertImage", el)

        activeButton = $(this).hasClass("wysihtml5-command-active")
        if !activeButton
          $modal.modal()
          false
        else
          true

      $toolbar.find('a[data-wysihtml5-command=insertVideo]').click ->
        $modal = $editor.find(".modal-video").clone()
        $tab_contents = $modal.find("[data-tab]")

        parseVideoUrl = (url) ->
          sources = [
            {
              provider: "youtube"
              regexp: /(?:youtube.com\/watch\?.*v=|youtu.be\/)([a-zA-Z0-9\-_]+)/
              result: "//www.youtube.com/embed/{{id}}"
            },
            {
              provider: "vimeo"
              regexp: /(?:vimeo.com\/)(\d+)/
              result: "//player.vimeo.com/video/{{id}}"
            }
          ]

          for source in sources
            if match = url.match(source['regexp'])
              return source['result'].replace("{{id}}", match[1])

          url

        $modal.find('[data-action=save]').click ->
          $content = $tab_contents.filter(":visible")
          el =
            src: parseVideoUrl($content.find("[name=url]").val())
            title: $content.find("[name=title]").val()
            height: $content.find("[name=height]").val()
            width: $content.find("[name=width]").val()

          editor.currentView.element.focus()
          editor.composer.commands.exec("insertVideo", el)

        activeButton = $(this).hasClass("wysihtml5-command-active")
        if !activeButton
          $modal.modal()
          false
        else
          true

  $ ->
    $('.activeadmin-wysihtml5:visible').activeAdminWysihtml5()
    $("a").bind "click", ->
      setTimeout(
        -> $('.activeadmin-wysihtml5:visible').activeAdminWysihtml5()
        50
      )

)(jQuery)
