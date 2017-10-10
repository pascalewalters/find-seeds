classdef Treatment
    
    properties
        ID
        Description
        DicomUID
    end
    
    methods
        function obj = Treatment(st)
            obj.ID = st.Children(2).Children.Data;
            obj.Description = st.Children(4).Children.Data;
            obj.DicomUID = st.Children(6).Children.Data;
        end
    end
    
end