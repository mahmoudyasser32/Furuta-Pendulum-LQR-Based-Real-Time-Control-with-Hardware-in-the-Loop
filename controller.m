l1 = 0.07;                            % Length of Arm(1)
L2 = 0.125;                           % Length of Arm(2)
I=2.05613759e-06;                     % Moment of inertia of motor
J=6.1912e-10;                         % Moment of inertia of Arm(1) at its center
J2_p=2e-6;                            % Moment of inertia of Arm(2) at its center
b_theta1 = 0.0077;                    % Damping coefficient for Arm(1)
b_theta2 = 5e-5;                      % Damping coefficient for Arm(2)
m_1 = 0.133;                          % mass of Arm(1)
m_2 = 0.02;                           % mass of Arm(2)
r = 29.5729;                           % motor coil resistance
L = 1.1181*1e-4;                      % motor coil inductance
g = 9.81;                             % gravity
Kt = 0.0199;                            % motor constant

% Substituting l1 = l1/2 and l2 = L2/2
l2 = L2 / 2;                         % center of mass of Arm (2)

J0 = (26^2*I+J) + m_2*l1^2;  % Moment of inertia of Arm 1 and motor
J2 = J2_p + m_2*l2^2;       % Moment of inertia of Arm 2

s = -1; % pendulum up (s=1) pendulum down (s=-1)
z=sqrt(r^2+(62832*L)^2);
d=2.2277e-06;
term_1 = J0 * J2 - m_2^2 * l1^2 * l2^2;

% Compute terms for B matrix
B31 = J2 / term_1;
B31 = B31 * 26*Kt/z;
B32 = s*m_2 * l2 * l1 / term_1;
B41 = s*m_2 * l2 * l1 / term_1;
B41 = B41 * 26*Kt/z;
B42 = J0 / term_1;

% Define the B matrix (inputs are volt and τ2)
B = [0    0;
     0    0;
     B31  B32;
     B41  B42];

% Compute terms for A matrix
A32 = g * m_2^2 * l2^2 * l1 / term_1;
A33 = -b_theta1 * J2 / term_1;
A33 = A33 - B31*(26^2*Kt^2/z);
A34 = s*-b_theta2 * m_2 * l2 * l1 / term_1;
A42 = s*g * m_2 * l2 * J0 / term_1;
A43 = s*-b_theta1 * m_2 * l2 * l1 / term_1;
A43 = A43 - B41*(26^2*Kt^2/z);
A44 = -b_theta2 * J0 / term_1;

% Define the state-space A matrix
A = [0,    0,    1,    0;
     0,    0,    0,    1;
     0,   A32,  A33,  A34;
     0,   A42,  A43,  A44];

% Output matrix C (identity matrix for state observation)
C = eye(4);  % Full-state observation

% Construct the D matrix (zero matrix)
D = zeros(4, 2);  % 4 outputs and 2 inputs

%LQR design
Q=diag([20 100 10 100]);% state matrix [theta alpha thetadot alphadot]
R=7;
K = lqr(A, B(:,1), Q, R);
