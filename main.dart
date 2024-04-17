import 'dart:io';

List<int> EI_MAG = [0x7f, 0x45, 0x4c, 0x46];

List<int> asList(
  int old,
  int newBytes,
) {
  assert(old < 0xFF);
  return List.filled(newBytes, 0)..[0] = old;
}

//void shstrtab(IOSink sink, List<) {

//}
enum Table {
  programHeaders,
  sectionHeaders,
}

enum sh_type {
  SHT_STRTAB, // 0x3  d
}

class SectionHeader {
  final int index;
  final String name;
  final sh_type type;
  final int flags;
  final int fileAddress;
  final int fileSize;
  final int memoryAddress;
  final int extraInfo;
  final int alignment;
  final int entrySize;

  SectionHeader(
      this.index,
      this.name,
      this.type,
      this.flags,
      this.fileAddress,
      this.fileSize,
      this.memoryAddress,
      this.extraInfo,
      this.alignment,
      this.entrySize);
}

class ProgramHeader {}

main(List<String> args) {
  if (args.length != 1) {
    print("This program takes exactly one (1) argument: the output file.");
    exit(1);
  }
  String arg = args.single;
  int fileHeaderSize = 0x40;

  int programHeaderTableIndex = fileHeaderSize;
  int programHeaderTableEntries = 0; // TODO: add pht entries
  int programHeaderEntrySize = 0x38;
  int sectionHeaderTableIndex = programHeaderTableIndex +
      programHeaderTableEntries * programHeaderEntrySize;
  int sectionHeaderTableEntries = 0; // TODO: add sht entries
  int sectionHeaderEntrySize = 0x40;
  int entrypoint = sectionHeaderTableIndex +
      sectionHeaderTableEntries * sectionHeaderEntrySize;
  List<int> e_entry = asList(entrypoint, 8);
  List<int> e_phoff = asList(programHeaderTableIndex, 8);
  List<int> e_shoff = asList(sectionHeaderTableIndex, 8);
  List<int> e_flags = [
    // set to zeros in ps20323:/bin/ls
    0x00,
    0x00,
    0x00,
    0x00,
  ];
  List<int> e_ehsize = asList(fileHeaderSize, 2);
  List<int> e_phentsize = asList(programHeaderEntrySize, 2);
  List<int> e_phnum = asList(programHeaderTableEntries, 2);
  List<int> e_shentsize = asList(sectionHeaderEntrySize, 2);
  List<int> e_shnum = asList(sectionHeaderTableEntries, 2);
  IOSink exe = File(arg).openWrite();
  exe.add(EI_MAG); // this is a ELF file!
  exe.add([0x02]); // EI_CLASS - 64-bit
  exe.add([0x01]); // EI_DATA - little-endian
  exe.add([0x01]); // EI_VERSION: ELF version number
  exe.add([0x00]); // EI_OSABI: target operating system ABI - System V
  exe.add([0x00]); // EI_ABIVERSION: unused
  exe.add(List.filled(7, 0)); // EI_PAD: padding for 0x10 alignment
  exe.add([0x02, 0x00]); // e_type - ET_EXEC (executable file)
  exe.add([0x3E, 0x00]); // e_machine - AMD x86-64
  exe.add([0x01, 0x00, 0x00, 0x00]); // e_version: ELF version number
  exe.add(e_entry); // entry point
  exe.add(e_phoff); // program header table index
  exe.add(e_shoff); // section header table index
  exe.add(e_flags); // flags
  exe.add(e_ehsize); // file header size
  exe.add(e_phentsize); // program header entry size
  exe.add(e_phnum); // program header table entries
  exe.add(e_shentsize); // section header entry size
  exe.add(e_shnum); // section header table entries
  exe.add([
    0x00,
    0x00,
  ]); // e_shstrndx: index of the section header table entry that contains the section names
  exe.close();
}
