
//最大の純アルコール量を算出
function calc_purealcohol(gender, age, self_evaluation){
    const base =(gender = 0)? 20 : 10;
    const age_minus =(age >=65)? -5 : 0;
    let self_evaluation_minus;

    switch(self_evaluation){//0:かなり弱い，1:弱い，2:普通，3:強い
        case 0:
            self_evaluation_minus = -5;
            break;
        case 1:
            self_evaluation_minus = -3;
            break;
        case 2:
            self_evaluation_minus = 0;
            break;
        case 3:
            self_evaluation_minus = 5;//本当はconstしたいけどswitchではできないのでこのまま
    }
    return Math.max(0,base + age_minus + self_evaluation_minus);
}

const alcohollist = [
    { name: "ビールA", purealcohol: 14 }, // 例：350ml缶あたりの純アルコール量(g)
    { name: "ビールB", purealcohol: 10 },
    { name: "チューハイX", purealcohol: 21 },
    { name: "チューハイY", purealcohol: 17 },
    { name: "サワーP", purealcohol: 7 },
    { name: "サワーQ", purealcohol: 12 },
];

const drinker_info = {gender : 0, age : 30,self_evaluation : 2}; //例
const safe_alcohol_limit = calc_purealcohol(
    drinker_info.gender,
    drinker_info.age,
    drinker_info.self_evaluation
)
let purealcohol_remain = safe_alcohol_limit;
const recommend_list = [];
const recommend_max = 5;

function alcohol_random(purealcohol_remain,recommend_list,recommend_max){//ランダム選出
    for(let i = 0; i < recommend_max; i++){
        if (purealcohol_remain <= 0){
            break;//飲めるアルコール量が0なら中止
        }
        let selected_canID = alcohollist[Math.floor(Math.random()*alcohollist.length)];//ランダム番号
        let selected_can_purealcohol = selected_canID.purealcohol;
        
        if (purealcohol_remain >= selected_can_purealcohol){
            recommend_list.push({name: selected_canID.name, purealcohol: selected_can_purealcohol});
            purealcohol_remain -= selected_can_purealcohol;
        }else{
            break;//もう飲めないのでループ終了
        }
    }
    return recommend_list;
}
