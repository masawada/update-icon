$(function() {
  $imageSelector = $('.image-selector');
  $fileInput = $('.file-input');
  $submitButton = $('.submit');

  if (!$imageSelector) { return; }

  var setImageSelectorWidth = function() {
    var width = $imageSelector.width();
    $imageSelector.height(width);
    $imageSelector.css('lineHeight', width + 'px');
  };

  // resize handler
  $(window).on('resize', setImageSelectorWidth);
  setImageSelectorWidth();

  // image selector click/change handler
  $imageSelector.on('click', function() {
    $fileInput.trigger('click');
  });

  $fileInput.on('change', function(rawEvent) {
    var e = rawEvent.originalEvent;
    var file = e.target.files[0];
    if (!file.type.match('image.*')) { return; }

    // read and set img
    var fileReader = new FileReader();
    fileReader.onload = function(e) {
      $imageSelector.empty();
      $imageSelector.append($('<img>').attr('src', e.target.result));
      $submitButton.show();
    };
    fileReader.readAsDataURL(file);
  });

  // confirm
  $submitButton.on('click', function() {
    if (!confirm('この画像に更新して良いですか？')) {
      return false;
    }
  });
});
