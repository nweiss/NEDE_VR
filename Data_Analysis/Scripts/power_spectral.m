

% pxx = nan ( size );
% 
% size ( pxx )


pxx = [];
power_trial = [];
for i = 1:size(eeg,3)
    fs = 256;
    power_trial(:,i) = sum(eeg(:,:,i).^2,2);
    %[pxx(i,:,:),f] = pwelch(squeeze(eeg(:,:,i))',385,fs/2,fs,fs);
end


%%

size ( pxx )


aRes = squeeze ( mean ( pxx, 1 ) );

size ( aRes )


figure ( );

    plot ( f, log ( aRes(:,:) ) )


% figure ( );
% 
% iR = 8;
% iC = 8;
% 
% for ( k = 1:size (aRes,1 ) )
%     for ( p = 1:size ( aRes, 2 ) )
%    
%         subplot ( iR, iC, k );
%         
%     end
% end
% 
% 
% 
