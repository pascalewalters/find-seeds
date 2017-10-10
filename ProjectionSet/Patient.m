classdef Patient
    properties
       FirstName
       MiddleName
       LastName
       ID
    end
    
    methods
        function obj = Patient(st)
            obj.FirstName = st.Children(2).Children.Data;
            try
                obj.MiddleName = st.Children(4).Children.Data;
            catch
                obj.MiddleName = '';
            end
            obj.LastName = st.Children(6).Children.Data;
            obj.ID = st.Children(8).Children.Data;
        end
    end
end