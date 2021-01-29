"use strict";

if ($('.ahd-listing').length) {
  $(
    function() {
      var that = {};

      var my_bit;
      var show_template;
      var edit_template;

      function toggleVisibility() {
        if ($(this).hasClass('folded')) {
          $(this).slideDown();
          $(this).removeClass('folded');
        } else {
          $(this).slideUp();
          $(this).addClass('folded');
        }
      }

      function setVisible(thing) {
        if ($(thing).hasClass('folded')) {
          $(thing).slideDown();
          $(thing).removeClass('folded');
        }
      }

      function setHidden(thing) {
        if (!$(thing).hasClass('folded')) {
          $(thing).slideUp();
          $(thing).addClass('folded');
        }
      }

      function setThisVisible() {
        setVisible(this);
      }

      function setThisHidden() {
        setHidden(this);
      }

      function setTextHide() {
        $(this).text("Hide");
      }

      function setTextShow() {
        $(this).text("Show");
      }

      function clickHandler(event) {
        var button = event['currentTarget'];
        var existing_button_text = $(button).text()
        //
        //  An "Xxxx all" button?
        //
        var doing_all = /all$/.test(existing_button_text);
        var showing = /^Show/.test(existing_button_text);
        //
        //  Want the parent *row* of the current target.
        //
        var my_row = $(button).closest(".arow");
        var target = $(my_row).next();
        //
        //  Now the processing diverges a tiny bit.
        //
        if (doing_all) {
          //
          //  Then its next sibling.  This is a container for all the items
          //  which we are going to affect.
          //
          if (showing) {
            $(target).find('.foldable').each(setThisVisible);
            $(target).find('.toggle').each(setTextHide);
            $(button).text("Hide all");
          } else {
            $(target).find('.foldable').each(setThisHidden);
            $(target).find('.toggle').each(setTextShow);
            $(button).text("Show all");
          }
        } else {
          //
          //  We already have the item which we want to affect.
          //
          var thing = target[0];
          if (showing) {
            setVisible(thing);
            $(button).text("Hide");
          } else {
            setHidden(thing);
            $(button).text("Show");
          }
        }
      }

      function updateOK(data, textStatus, jqXHR) {
        var pupil_id = data.id;
        var owner_id = data.owner_id;
        var minutes = data.minutes;

        var div = my_bit.find('div#ahd-pupil-' + pupil_id);
        if (div.length) {
          $(div).html(show_template({mins: minutes}));
          $(div).click(minsClickHandler);
        }
        my_bit.find('div#ahd-pupil-errors-' + owner_id).text("");
      }

      function updateFailed(jqXHR, textStatus, errorThrown) {
        var json = jqXHR.responseJSON;
        var pupil_id = json.id;
        var owner_id = json.owner_id;
        var errors = json.errors;

        var text = errors.minutes[0];
        my_bit.find('div#ahd-pupil-errors-' + owner_id).text(text);
      }

      function minsClickHandler(event) {
        var div = event['currentTarget'];
        //
        //  Need to disable click handler temporarily.
        //
        $(div).off('click');
        //
        //  There should be a span within this, which we are going to
        //  change to be an input field.
        //
        var org_contents = $(div).children('span').html();
        $(div).html(edit_template({mins: org_contents}));
        $(div).children('input').focus();
        //
        //  We will terminate input if the user presses Enter or Escape.
        //
        $(div).children('input').keyup(function(e) {
          if (e.key === 'Escape') {
            //
            //  Revert things to how they were.
            //
            var prev_value = $(e.target).data('prev-value');

            $(div).html(show_template({mins: prev_value}));
            $(div).click(minsClickHandler);
            return false;
          } else if (e.key == 'Enter') {
            //
            //  We need to send the new value up to the host.
            //
            var new_value = $(e.target).val();
            //
            //  And the ID of the record to be updated?
            //
            var parent_id = $(e.target).parent().attr('id');
            var id = parent_id.replace("ahd-pupil-", "");
            var prepared_data = JSON.stringify({
              ad_hoc_domain_pupil_course: {
                minutes: new_value
              }
            });
            $.ajax({
              url: '/ad_hoc_domain_pupil_courses/' + id,
              type: 'PATCH',
              context: this,
              dataType: 'json',
              contentType: 'application/json',
              data: prepared_data
            }).done(updateOK).
               fail(updateFailed);
            return false;
          } else {
            return true;
          }
        });
        //
        //  Likewise if we lose focus.
        //
        $(div).children('input').focusout(function(e) {
          //
          //  Revert things to how they were.
          //
          var prev_value = $(e.target).data('prev-value');

          $(div).html(show_template({mins: prev_value}));
          $(div).click(minsClickHandler);
        });
      }

      that.init = function() {
        my_bit = $('.ahd-listing');
        //
        //  We use templates for modifying the contents of the
        //  mins span/field.
        //
        show_template = _.template($('#ahd-show-mins').html());
        edit_template = _.template($('#ahd-edit-mins').html());
        $('.toggle').click(clickHandler);
        $('.mins').click(minsClickHandler);

        window.updateTotals = function(subject_id, num_staff, num_pupils) {
          var target_row = $('div#ahd-subject-' + subject_id);
          $(target_row).find('.num-staff').text(num_staff + ' staff');
          $(target_row).find('.num-pupils').text(num_pupils + ' pupils');
        }

        //
        //  We will use the CSS convention of indexing from 1 (nasty).
        //
        window.insertSubjectAt = function(text, index, owner_id) {
          //
          //  We convert the provided text to being an HTML element
          //  before we insert it so we can attach the click handler.
          //
          var html = $.parseHTML(text);
          $(html).find('.toggle').click(clickHandler);
          //
          //  And now insert.
          //
          var marker = $('div#ahd-subject-listing > div:nth-child(' + index + ')');
          if (marker.length === 0) {
            marker = $('div#ahd-subject-listing > div:last-child');
          }
          marker.before(html);
          //
          //  And now a bit of tidying up.
          //
          var name_field = $('#subject-element-name-' + owner_id);
          name_field.focus();
          name_field.val('');
          $('#ahd-subject-errors').html("");
        }
      };

      return that;
    }().init
  );

}
