/// Eixo afetado por uma alça de redimensionamento de borda de um `GridNode`
/// (ai/EDITAR_LOJA_VIEW.md §6.3) — usado pelas alças de borda do `ItemNode`,
/// que (ao contrário do pinça) alteram só a largura, só a altura, ou ambas
/// dependendo de qual borda/canto o usuário arrasta.
enum EixoRedimensionamento { larguraApenas, alturaApenas, ambos }
