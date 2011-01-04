describe('New Staged Message view', function(){
  var $d = window.open('').document;

  beforeEach(function(){
    $d.open();
    $d.write(
'<html><head></head><body><select id="input_type" name="input_type"><option value="">--Choose One--</option><option value="text">text</option><option value="file">file</option><option value="list">list</option></select><div id="inputPane"></div><div id="templates"><div class="textInput templates"><span>text</span></div><div class="fileInput templates"><span>file</span><div class="listInput templates"><span>list</span></div></div></body></html>'
    );
    $d.close();
  });

  it('has an input selector', function(){
    var $input_type;
    expect(function(){
      $input_type = jQuery('select#input_type', $d);
    }).not.toThrow();

    expect($input_type).toBeDefined();
    expect($input_type).not.toBeNull();

    var $size;
    expect(function(){
      $size = $input_type.size();
    }).not.toThrow();

    expect($size).toEqual(1);
  });

  it('has an inputPane div', function(){
    var $input_pane;
    expect(function(){
      $input_pane = jQuery('div#inputPane', $d);
    }).not.toThrow();

    expect($input_pane).toBeDefined();
    expect($input_pane).not.toBeNull();

    var $size;
    expect(function(){
      $size = $input_pane.size();
    }).not.toThrow();

    expect($size).toEqual(1);
  });

  it('adds the appropriate div when the selector is changed', function(){
    $input_type = jQuery('select#input_type', $d);

    $input_type.val('file').trigger('change');
    expect($input_type.val()).toEqual('file');

    /* to be continued */
    var $input_pane;
    expect(function() {
      $input_pane = jQuery('div#inputPane', $d);
    }).not.toThrow();
    expect($input_pane).toBeDefined();
    expect($input_pane).not.toBeNull();
    expect($input_pane.children().size()).toEqual(1);
    expect($input_pane.text()).toMatch(/file/);
  });
});
