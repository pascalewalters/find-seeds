% Determine which frame index is associated with the projection taken when
% the kV imager is closest to 0 degrees

for i = 1:length(ps.SeedSeq)
    if ps.Frames(ps.SeedSeq(i)).kVAngle > -5 && ps.Frames(ps.SeedSeq(i)).kVAngle < 5
        ps.SeedSeq(i)
        ps.Frames(ps.SeedSeq(i)).kVAngle
    end
end