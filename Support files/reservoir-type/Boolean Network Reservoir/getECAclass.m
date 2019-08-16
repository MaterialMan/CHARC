function [class,symmetry] = getECAclass(rule_number)


%% assign equivalent rules
switch(rule_number)
    case 255
        rule_number = 0;
    case {127}
        rule_number = 1;
    case {16, 191, 247}
        rule_number = 2;
    case {17, 63, 119}
        rule_number = 3;
    case {223}
        rule_number = 4;
    case {95}
        rule_number = 5;
    case {20, 159, 215}
        rule_number = 6;
    case {21, 31, 87}
        rule_number = 7;
    case {64, 239, 253}
        rule_number = 8;
    case {65, 111, 125}
        rule_number = 9 ;
    case {80, 175, 245}
        rule_number = 10 ;
    case {47, 81, 117 }
        rule_number = 11 ;
    case {68, 207, 221 }
        rule_number = 12;
    case {69, 79, 93 }
        rule_number = 13 ;
    case {84, 143, 213 }
        rule_number =14  ;
    case {85 }
        rule_number = 15;
    case {183 }
        rule_number = 18;
    case {55 }
        rule_number = 19 ;
    case {151 }
        rule_number = 22 ;
    case {66, 189, 231 }
        rule_number = 24 ;
    case {61, 67, 103 }
        rule_number = 25 ;
    case {82, 167, 181 }
        rule_number = 26 ;
    case {39, 53, 83 }
        rule_number = 27 ;
    case {70, 157, 199 }
        rule_number = 28 ;
    case {71 }
        rule_number = 29;
    case {86, 135, 149 }
        rule_number = 30 ;
    case {251 }
        rule_number = 32 ;
    case {123 }
        rule_number = 33 ;
    case {48, 187, 243 }
        rule_number =34  ;
    case {49, 59, 115 }
        rule_number =35  ;
    case {219 }
        rule_number =36 ;
    case {91 }
        rule_number = 37;
    case {52, 155, 211 }
        rule_number = 38 ;
    case {96, 235, 249 }
        rule_number = 40 ;
    case {97, 107, 121 }
        rule_number = 41;
    case {112, 171, 241 }
        rule_number =42 ;
    case {113 }
        rule_number = 43 ;
    case {100, 203, 217 }
        rule_number = 44 ;
    case {75, 89, 101 }
        rule_number = 45 ;
    case {116, 139, 209 }
        rule_number = 46;
    case {179 }
        rule_number = 50 ;
    case {147 }
        rule_number = 54 ;
    case {98, 185, 227}
        rule_number =56;
    case {99}
        rule_number = 57 ;
    case {114, 163, 177}
        rule_number = 58 ;
    case {102, 153, 195}
        rule_number = 60;
    case {118, 131, 145}
        rule_number = 62;
    case {237}
        rule_number = 72 ;
    case {109}
        rule_number = 73 ;
    case {88, 173, 229}
        rule_number = 74 ;
    case {205}
        rule_number = 76;
    case {92, 141, 197}
        rule_number = 78 ;
    case {165}
        rule_number = 90 ;
    case {133}
        rule_number = 94 ;
    case {233}
        rule_number = 104 ;
    case {120, 169, 225 }
        rule_number = 106 ;
    case {201}
        rule_number = 108 ;
    case {124, 137, 193}
        rule_number = 110 ;
    case {161}
        rule_number = 122 ;
    case {129}
        rule_number = 126;
    case {254}
        rule_number =128  ;
    case {144, 190, 246}
        rule_number = 130 ;
    case {222}
        rule_number = 132 ;
    case {148, 158, 214}
        rule_number = 134 ;
    case {192, 238, 252}
        rule_number = 136 ;
    case {174, 208, 224}
        rule_number = 138 ;
    case {196, 206, 220}
        rule_number = 140 ;
    case {212}
        rule_number = 142 ;
    case {182}
        rule_number = 146 ;
    case {188, 194, 230}
        rule_number = 152 ;
    case {166, 180, 210}
        rule_number = 154 ;
    case {198}
        rule_number = 156 ;
    case {250}
        rule_number = 160 ;
    case {176, 186, 242}
        rule_number = 162;
    case {218}
        rule_number = 164 ;
    case {224, 234, 248}
        rule_number = 168 ;
    case {240}
        rule_number = 170 ;
    case {202, 216, 228}
        rule_number = 172 ;
    case {226}
        rule_number = 184 ;
    case {236}
        rule_number = 200;
end

%% get class
% class 0: not classified in literature
% Class 1: evolve to uniform behaviour;
% Class 2: evolve to periodic behaviour;
% Class 3: evolve to chaotic behaviour;
% Class 4: evolve to complex behaviour.
switch(rule_number)
    
    case {0, 8, 32, 40, 128, 136, 160, 168}
        class = 1;
        
    case {1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 19, 23,...
            24, 25, 26, 27, 28, 29, 33, 34, 35, 36, 37, 38, 42,...
            43, 44, 46, 50, 51, 56, 57, 58, 62, 72, 73, 74, 76,...
            77, 78, 94, 104, 108, 130, 132, 134, 138, 140, 142,...
            152, 154, 156, 162, 164, 170, 172, 178, 184, 200,...
            204, 232}
        class = 2;
        
    case {18, 22, 30, 45, 60, 90, 105, 122, 126, 146, 150}
        class = 3;
        
    case {41, 54, 106, 110}
        class = 4;
        
    otherwise % no class
        class = 0;
end

%% get symmetry
% 1 = symmetric
% 2 = semi-asymmetric
% 3 = full-asymmetric
switch(rule_number)
    %symmetric
    case {0, 1, 4, 5, 18, 19, 22, 23, 32, 33, 36, 37,...
            50, 51, 54, 72, 73, 76, 77, 90, 94, 104,...
            105, 108, 122, 126, 128, 132, 146, 150,...
            160, 164, 178, 200, 204, 232}
        symmetry = 1;
        %semi-asymmetric
    case {2, 3, 6, 7, 8, 9, 12, 13, 26, 27, 30, 34, 35,...
            38, 40, 41, 44, 45, 58, 62, 74, 78, 106,...
            110, 130, 134, 136, 140, 154, 162, 168,...
            172}
        symmetry = 2;
        %full-asymmetric
    case {10, 11, 14, 15, 24, 25, 28, 29, 42, 43, 46,...
            56, 57, 60, 138, 142, 152, 156, 170, 184}
        symmetry = 3;
        
    otherwise % not sure
        symmetry = 0;
end

