function [ output ] = BiasGen( input, amp, key )
%BiasGen bias generator for kitti
%   此处显示详细说明
    rng(key);
    output = amp/5 * sin(2*pi/5*input + rand()*5) + ...
            amp/3 * sin(2*pi/10*input + rand()*10) + ...
            amp/2 * sin(2*pi/50*input + rand()*50)+...
            amp * sin(2*pi/100*input + rand()*50);

end

