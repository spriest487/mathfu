
CXX=g++
CLANG_CC=clang
CLANG_CXX=clang++

IPHONE_PLATFORM_PATH = /Developer3.2b/Platforms/iPhoneOS.platform/Developer
IPHONE_ISYSROOT_PATH = $(IPHONE_PLATFORM_PATH)/SDKs/iPhoneOS3.1.2.sdk/
IPHONE_CC = $(IPHONE_PLATFORM_PATH)/usr/bin/g++ -isysroot $(IPHONE_ISYSROOT_PATH)   -arch armv7
# -mfloat-abi=softfp -mfpu=neon  

CXXFLAGS += -g -Iinclude -Wall -Wextra -pedantic -Wno-unused -O3 -fstrict-aliasing -ffast-math 

SPEC_SRC = $(wildcard spec/*.cpp)
SPEC_OBJ = $(SPEC_SRC:.cpp=.o)

BENCH_SRC = $(wildcard bench/*.cpp)
BENCH_OBJ = $(BENCH_SRC:.cpp=.o)

SUFFIX=

DEFAULT_CC=1

ifeq ($(FORCE_SCALAR),1)
	CXXFLAGS+= -DVECTORIAL_FORCED -DVECTORIAL_SCALAR
	SUFFIX=-scalar
endif

ifeq ($(FORCE_SSE),1)
	CXXFLAGS+= -DVECTORIAL_FORCED -DVECTORIAL_SSE -msse -msse2 -mfpmath=sse
	SUFFIX=-sse
endif

ifeq ($(FORCE_GNU),1)
	CXXFLAGS+= -DVECTORIAL_FORCED -DVECTORIAL_GNU 
	#-msse -msse2 -mfpmath=sse
	SUFFIX=-gnu
endif

ifeq ($(FORCE_NEON),1)
	CXXFLAGS+= -DVECTORIAL_FORCED -DVECTORIAL_NEON
	SUFFIX=-neon
	ARM=1
endif


ifeq ($(ARM),1)
ifeq ($(shell uname -s),Darwin)
	CC=$(IPHONE_CC)
	CXX=$(IPHONE_CC)
endif
#	CXXFLAGS+= -mcpu=cortex-a8 
	CXXFLAGS+= -mno-thumb -mfloat-abi=softfp -mfpu=neon
	DEFAULT_CC=0
endif

ifeq ($(CLANG),1)
	CC=$(CLANG_CC)
	CXX=$(CLANG_CXX)
	DEFAULT_CC=0
endif

ifeq ($(DEFAULT_CC),1)
#	CXXFLAGS += -msse -msse2 -mfpmath=sse
endif

ifeq ($(ASM),1)
	CC+= -S
	CXX+= -S
endif





all: specsuite$(SUFFIX)
	./specsuite$(SUFFIX)


full:
	FORCE_SCALAR=1 $(MAKE) clean 
	FORCE_SCALAR=1 $(MAKE) specsuite-scalar
	FORCE_GNU=1 $(MAKE) clean 
	FORCE_GNU=1 $(MAKE) specsuite-gnu
	FORCE_SSE=1 $(MAKE) clean 
	FORCE_SSE=1 $(MAKE) specsuite-sse
	FORCE_NEON=1 $(MAKE) clean 
	FORCE_NEON=1 $(MAKE) specsuite-neon
	./specsuite-scalar
	./specsuite-sse
	./specsuite-gnu

specsuite$(SUFFIX): $(SPEC_OBJ)
	$(CXX) $^ -o $@

depend:
	@echo DEP
	@makedepend -Y -- $(CXXFLAGS) -- $(SPEC_SRC) $(BENCH_SRC) > /dev/null 2>&1 
	@$(RM) Makefile.bak


benchmark$(SUFFIX): $(BENCH_OBJ)
	$(CXX) $^ -o $@

bench-full:
	FORCE_SCALAR=1 $(MAKE) clean 
	FORCE_SCALAR=1 $(MAKE) benchmark-scalar
	FORCE_GNU=1 $(MAKE) clean 
	FORCE_GNU=1 $(MAKE) benchmark-gnu
	FORCE_SSE=1 $(MAKE) clean 
	FORCE_SSE=1 $(MAKE) benchmark-sse
	FORCE_NEON=1 $(MAKE) clean 
	FORCE_NEON=1 $(MAKE) benchmark-neon
	./benchmark-scalar
	./benchmark-sse
	./benchmark-gnu

clean:
	rm -f $(SPEC_OBJ) $(BENCH_OBJ) benchmark$(SUFFIX) specsuite$(SUFFIX)

realclean: clean
	rm -f specsuite*


update_spec:
	./tools/update_spec.rb spec/spec_*.cpp

# DO NOT DELETE

spec/spec.o: spec/spec.h
spec/spec_main.o: spec/spec.h
spec/spec_simd4f.o: spec/spec_helper.h spec/spec.h include/vectorial/simd4f.h
spec/spec_simd4f.o: include/vectorial/config.h include/vectorial/simd4f_gnu.h
bench/add_bench.o: bench/bench.h
bench/bench.o: bench/bench.h include/vectorial/config.h
