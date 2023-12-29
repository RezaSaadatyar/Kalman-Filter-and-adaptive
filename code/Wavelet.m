function InputWRecons= Wavelet(data, wname, nLevel,Threshold_selection_Rule,Threshold_Type, display_fig)
if size(data, 1)<size(data, 2);data= data';end

ca=cell(size(data,2),nLevel);cd=ca;InputWRecons=zeros(size(data,1),size(data,2));
for j=1:size(data,2)
    for i=1:nLevel;[c,l] = wavedec(data(:,j),i,wname);ca{j,i}=appcoef(c,l,wname,i);end
    d=detcoef(c,l,1:nLevel);YY=[];for k=1:size(d,2);if nLevel==1;cd(j,k)={d};else;cd(j,k)=d(k);end;end
    %% De-noise'
    for i=1:nLevel
        aa=cd{j,i};THR=thselect(aa,Threshold_selection_Rule);Y=wthresh(data(:,j),Threshold_Type,THR);YY=[YY;Y];%#ok
    end
    InputWRecons(:,j)=waverec([appcoef(c,l,wname,nLevel);YY],l,wname);
end

if display_fig == "on"
    kk=0;
    figure;
    for k=1:size(data,2)
        Q(k+kk)=subplot(2,1,1);QL(k+kk)=plot(Q(k+kk),data(:,k));%#ok
        hold on;title('Raw Signal');QT(1)=ylabel(Q(k+kk),'Amp','FontName','Times New Roman');
        xlim([0, length(data)])
        Q(2*k)=subplot(2,1,2);QL(2*k)=plot(Q(2*k),InputWRecons(:,k));%#ok
        hold on;QT(2)=ylabel(Q(2*k),'Amp','FontName','Times New Roman');title('Reconstracted signal');kk=kk+1;
        xlim([0, length(data)])
    end
    xlabel('Sample','FontName','Times New Roman');
    %% Approximation & Detial
    kk=0;
    figure;
    for k=1:size(data,2)
        P(k+kk)=subplot(nLevel+1,2,1);PL(k+kk)=plot(P(k+kk),data(:,k));%#ok
        hold on;ylabel(P(k+kk),'Sig','FontName','Times New Roman');title('Signal and Approximations')
        xlim([0 length(data(:,k))])
        P(2*k)=subplot(nLevel+1,2,2);PL(2*k)=plot(P(2*k),data(:,k));%#ok
        hold on;ylabel(P(2*k),'Sig','FontName','Times New Roman');title('Signal and Detials');
        c=2;kk=kk+1;xlim([0 length(data(:,k))])
    end
    kk=numel(P);
    for i=1:nLevel
        c=c+1;
        for k=1:size(data,2)
            P(k+kk)=subplot(nLevel+1,2,c);PL(k+kk)=plot(P(k+kk),ca{k,i});hold on;
        end
        xlim([0 length(ca{k,i})])
        ylabel(P(k+kk),['a_{' num2str(i) '}']);c=c+1;kk=numel(P);if i==nLevel;xlabel('Sample');end
        for k=1:size(data,2)
            P(k+kk)=subplot(nLevel+1,2,c);
            if nLevel==1;PL(k+kk)=plot(P(k+kk),cd{k,i});hold on;
            else;PL(k+kk)=plot(P(k+kk),cd{k,i});hold on;end
        end
        ylabel(P(k+kk),['d_{ ' num2str(i) '}']);kk=numel(P);if i==nLevel;xlabel('Sample');end
        xlim([0 length(cd{k,i})])
    end
end
end