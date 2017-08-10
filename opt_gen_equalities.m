%% General Equalities

%% Energy Balances
%% Electrical
if isempty(vc_v)==0
    vc_cop=zeros(length(vc_cool),size(vc_v,2));
    for i=1:length(vc_cool)
        vc_cop(i,:)=1./vc_v(2,:);
    end
else
    vc_cop=zeros(length(cooling),1);
end



Constraints=[];
Constraints= [import + sum(dghr_elec,2) == elec(1:endpts(length(endpts)),2) + sum(vc_cop.*vc_cool,2) ];
Const_num=endpts(length(endpts));

%% Cooling
if isempty(acp_v) == 1
Constraints=[Constraints
    vc_cool + sum(acs_cool,2) + sum(ac_cool,2) == cooling(1:endpts(length(endpts)))];
elseif isempty(acp_v) == 0
    if acp_v(end) == 0
        Constraints=[Constraints
            vc_cool(1) + sum(acs_cool(1,:),2) + sum(ac_cool(1,:),2) + sum(acp_cool(1,:),2) == cooling(1)
            vc_cool(2:endpts(length(endpts))) + sum(acs_cool(2:endpts(length(endpts)),:),2) ...
            + sum(ac_cool(2:endpts(length(endpts)),:),2) + sum(acp_cool(2:endpts(length(endpts)),:),2) + sum(acp_dchrg,2) == cooling(2:endpts(length(endpts)))];            
    elseif acp_v(end) == 1
        Constraints=[Constraints
            vc_cool(1) + sum(acp_cool(1,:),2) + sum(acs_cool(1,:),2) + sum(ac_cool(1,:),2) == cooling(1)
            vc_cool(2:winter_time_count) + sum(acp_cool(2:winter_time_count,:),2) + sum(acp_dchrg,2) + sum(acs_cool(2:winter_time_count,:),2) + sum(ac_cool(2:winter_time_count,:),2) == cooling(2:winter_time_count)
            vc_cool(winter_time_count+1:endpts(length(endpts))) + sum(acp_cool(winter_time_count+1:endpts(length(endpts)),:),2) + sum(acs_cool(winter_time_count+1:endpts(length(endpts)),:),2) + sum(ac_cool(winter_time_count+1:endpts(length(endpts)),:),2) == cooling(winter_time_count+1:endpts(length(endpts)))];  
    end    
end
Const_num=Const_num+endpts(length(endpts));
%% Heating
Constraints=[Constraints
    boil + sum(hru_heat,2) == heating(1:endpts(length(endpts)))];
Const_num=Const_num+endpts(length(endpts));
%% Utility Natural Gas Change
for i=1:length(endpts)
    if i==1
        start=1;
        finish=endpts(i);
    else
        start=endpts(i-1)+1;
        finish=endpts(i);
    end
    
    Constraints=[Constraints
        c1*(sum((1/boil_v(2)).*boil(start:finish))+sum(sum(dghr_fuel(start:finish,:)))) == ng_use_v'*lambda(:,i)
        sum(lambda(:,i)) == 1
        sum(sig(:,i)) == 1];
    Const_num=Const_num+3;
end