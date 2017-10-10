classdef Field
    
    properties
        Id
        Description
    end
    
    methods
        function obj = Field(st)
            obj.Id = st.Children(2).Children.Data;
            % TODO: Fix this
%             if isempty(st.Children(4).Children)
%                 obj.Description = '';
%             else
%                 obj.Description = st.Children(4).Children.Data;
%             end
        end
    end
    
end


