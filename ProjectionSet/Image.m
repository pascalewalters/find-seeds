classdef Image
    
    properties
        kV
        mA
        ms
        Acquisition
        Width
        Height
        Depth
        DicomUID
        CTDIvol
        CTDIPhantomType
        AbsoluteTableLatPosIEC1217_MM
        AbsoluteTableLongPosIEC1217_MM
        AbsoluteTableVertPosIEC1217_MM
    end
    
    methods
        function obj = Image(st)
            obj.kV = st.Children(2).Children.Data;
            obj.mA =  st.Children(4).Children.Data;
            obj.ms = st.Children(6).Children.Data;
            obj.Acquisition = st.Children(8).Children.Data;
            obj.Width = st.Children(10).Children.Data;
            obj.Height = st.Children(12).Children.Data;
            obj.Depth = st.Children(14).Children.Data;
            obj.DicomUID = st.Children(16).Children.Data;
            obj.CTDIvol = st.Children(18).Children.Data;
            obj.CTDIPhantomType = st.Children(20).Children.Data;
            obj.AbsoluteTableLatPosIEC1217_MM = st.Children(22).Children.Data;
            obj.AbsoluteTableLongPosIEC1217_MM = st.Children(24).Children.Data;
            obj.AbsoluteTableVertPosIEC1217_MM = st.Children(26).Children.Data;
        end
    end
    
end
