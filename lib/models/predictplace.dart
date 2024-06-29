class Predictplace{
  String? place_id;
  String? prim_text;
  String? sec_text;

  Predictplace({
    this.place_id,
    this.prim_text,
    this.sec_text,
  });
  Predictplace.fromJson(Map<String, dynamic> jsonData){
    place_id = jsonData["Place_ID"];
    prim_text = jsonData["Structure_Formatting"]["prim_text"];
    sec_text = jsonData["Structure_Formatting"]?["sec_text"];

  }
}