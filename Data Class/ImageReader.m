classdef (Abstract) ImageReader < handle
    %written by
    %C.P.Richter
    %Division of Biophysics / Group J.Piehler
    %University of Osnabrueck
    
    properties(Abstract,Transient)
        Parent
    end %properties
    
    methods(Abstract)
        initialize(this)
        has_parent(this)    
        set_parent(this,objParent)
        get_image_height(this)
        get_image_width(this)
        get_image_count(this)
        get_time_slice(this,TOI,COI)
        get_image_stack(this,COI)
    end %methods
end %class