# SPINOFF.plugin
# FOR GENERATING DESIGN OPTIONS IN SKETCHUP
# AM 120919-152641 v001 added logic for initial conditions
# AM 120830-112506 v000 to copy selection to new layer as a group

require "sketchup.rb"
module XASpinoff
    def self.start
        m = Sketchup.active_model
        s = m.selection
        e = m.active_entities
        l = m.layers
        p = m.pages
        result = inputbox(["Option"], [l.unique_name], "name your new option (layer & scene)")
        return unless result
        optionname = result[0].strip
        layer = l.add optionname
        layer.page_behavior = LAYER_IS_HIDDEN_ON_NEW_PAGES

        #check for selection not empty
        #check nested group? parent should not change layer

        
        active_array=s.to_a
  
        #behave differently if selection is a group already
        if (s.length == 1 && s[0].typename == "Group")
          #UI.messagebox("1!")       
          group=s[0]
        else
          group = e.add_group(active_array)
        end

        if (group.layer.name=="Layer0") #the Sketchup default layer
          #UI.messagebox("looks like this is the first time spinning off an option, so this is going to be the base")
          group.layer=layer
          #put selection on its own layer
          #turn off layer in all scenes
          #create scene wi new layer on
        else
          copy=group.copy
          copy.layer=layer
        end
        #group.erase!
        
        p.each { |page| page.set_visibility(layer, false) }
        newpage=p.add optionname
        #m.pages[-1].name.to_i.to_s+1.to_s
        p[newpage.name].set_visibility(layer, true)
    end
end

unless file_loaded?("xa_spinoff.rb")
    UI.menu.add_item("xa_spinoff") {XASpinoff.start}
    # toolbar setup
    s=Sketchup.active_model
    p=s.pages
    toolbar = UI::Toolbar.new "Spinoff"
    
    cmd = UI::Command.new("Show Layer Everywhere") {
      p.each { |page| page.set_visibility(s.selection[0].layer,true)}
    }
    cmd.small_icon = "xa_layoff_all.png"
    cmd.large_icon = "xa_layon_all.png"
    cmd.tooltip = "turn selected object's layer on in all pages"
    cmd.status_bar_text = "selected object layer turns on"
    cmd.menu_text = "turn on"
    toolbar = toolbar.add_item cmd
    toolbar.show

    file_loaded("xa_spinoff.rb")
end

#note, this does not address model view, only layer visibility in particular
#if sel[0].typename == "Group"
#group = active_array
#else