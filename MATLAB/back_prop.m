function [c_f,ep,w3,w2,w1,b3,b2,b1,a3] = back_prop(X,w3,w2,w1,b3,b2,b1,t,eta)

c_f = [];
ep = [];

for j = 1:15000
    C=0;
    dCdw1=0;
	dCdw2=0;
    dCdw3=0;
    dCdb1=0;
	dCdb2=0;
    dCdb3=0;
	
	for i=1:size(X,2)
	   k = X(:,i);
	   z1 = w1 * k + b1;
	   %a1 = sigmoid(z1) ; 
	   a1 = 1./(1+exp(-z1)); 
	   dadz1 = (1-a1).*a1;
	   
	   z2 = w2 * a1 + b2;
	   %a2 = sigmoid(z2) ;
	   a2 = 1./(1+exp(-z2)); 
	   dadz2 = (1-a2).*a2;
	   
	   z3 = w3 * a2 + b3;
	   %a3 = sigmoid(z3) ;
	   a3 = 1./(1+exp(-z3)); 
	   dadz3 = (1-a3).*a3;
	   
	   tx=t(:,i);
	   
	   Q=sum((tx-a3).^2)/2;
	   C = C + Q;
	   
	   delta3 = (a3-tx) .* dadz3;
	   delta2 = (w3.' * delta3).*dadz2;
	   delta1 = (w2.' * delta2).*dadz1;
	   
	   o = (a2 * (delta3).').';
	   dCdw3 = dCdw3 + o;
	   o = (a1 * (delta2).').';
	   dCdw2 = dCdw2 + o ;
	   o = (k * (delta1).').';
	   dCdw1 = dCdw1 + o ;
	   
	   dCdb3 = dCdb3 + delta3;
	   dCdb2 = dCdb2 + delta2;
	   dCdb1 = dCdb1 + delta1;
	   
	end
    
	w1 = w1 - eta * dCdw1;
	w2 = w2 - eta * dCdw2;
    w3 = w3 - eta * dCdw3;
    b1 = b1 - eta * dCdb1;
	b2 = b2 - eta * dCdb2;
    b3 = b3 - eta * dCdb3;
	
	c_f = [c_f, C];
	ep = [ep, j];
	
    text = sprintf('epoch = %d | cost function = %d',j,C);
    disp(text);
	%title('Training | Epoch : %d', j);
	
	
end