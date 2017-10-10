% This script plots the positions of the seeds on projection images

for i = 50:100
   seq = ps.SeedSeq(i);   
   figure
   ps.Frames(seq).showFrame
   hold on
   plot(ps.Frames(seq).RedSeed(1), ps.Frames(seq).RedSeed(2), 'r*')
   plot(ps.Frames(seq).BlueSeed(1), ps.Frames(seq).BlueSeed(2), 'b*')
   plot(ps.Frames(seq).YellowSeed(1), ps.Frames(seq).YellowSeed(2), 'y*')
   plot(ps.Frames(seq).GreenSeed(1), ps.Frames(seq).GreenSeed(2), 'g*')
end