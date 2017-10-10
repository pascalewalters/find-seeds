classdef Station
    properties
       StationName
       LinacID
    end
    
    methods
        function obj = Station(st)
            obj.StationName = st.Children(2).Children.Data;
            obj.LinacID = st.Children(4).Children.Data;
        end
    end
end