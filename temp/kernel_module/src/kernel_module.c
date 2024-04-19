#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/ioport.h>
#include <asm/errno.h>
#include <asm/io.h>


MODULE_INFO(intree, "Y");
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Aleksandr Rogaczewski");
MODULE_DESCRIPTION("Simple kernel module for SYKT/SYKOM lecture");
MODULE_VERSION("0.01");
#define SYKT_MEM_BASE_ADDR (0x00100000)
#define SYKT_MEM_SIZE (0x8000)
#define SYKT_EXIT (0x3333)
#define SYKT_EXIT_CODE (0x7F)
#define SYKT_QEMU_EXIT_VAL (0x00007777)
 


#define SYKT_GPIO_ADDR_SPACE (baseptr) 
#define SYKT_GPIO_ARG2_ADDR (SYKT_GPIO_ADDR_SPACE+0x00000388)
#define SYKT_GPIO_ARG1_ADDR (SYKT_GPIO_ADDR_SPACE+0x00000380)
#define SYKT_GPIO_RESULT_ADDR (SYKT_GPIO_ADDR_SPACE+0x00000390)
#define SYKT_GPIO_ONES_ADDR (SYKT_GPIO_ADDR_SPACE+0x00000398)
#define SYKT_GPIO_STATUS_ADDR (SYKT_GPIO_ADDR_SPACE+0x000003A0)



void __iomem *baseptr;
static struct kobject *kobj_ref;
static int raba1;
static int raba2;
static int rabw;
static int rabl;
static int rabb;

// odczyt argumentu arg1 
//store odczyt i zapis
//show odczyt z modułu
static bool is_hex(const char *buf, size_t count) {
    for (size_t i = 0; i < count; ++i) {
        char c = buf[i];
        if (c == '\n' || c == '\0') { // Jeśli napotkano koniec linii lub koniec ciągu, zakończ pętlę teraz powinny widzieć koniec linii 
            break;
        }
        if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F'))) {
            return false;
        }
    }
    return true;
}

static bool has_six_symbols(const char *buf, size_t count) {
    return (count < 8);  // +znak końca linii
}


static ssize_t raba1_store(struct kobject *kobj,struct kobj_attribute *attr,const char *buf, size_t count)
{

if (!is_hex(buf, count)) {
        printk(KERN_ERR "Invalid hex string: %.*s\n", (int)count, buf);
        return -EINVAL;
    }

    if (!has_six_symbols(buf, count)) {
        printk(KERN_ERR "Invalid input: Must have max 6 symbols\n");
        return -EINVAL;
    }

    sscanf(buf,"%x",&raba1);
    writel(raba1, SYKT_GPIO_ARG1_ADDR);
    return count;
}


static ssize_t raba2_store(struct kobject *kobj,struct kobj_attribute *attr,const char *buf, size_t count)
{

if (!is_hex(buf, count)) {
        printk(KERN_ERR "Invalid hex string: %.*s\n", (int)count, buf);
        return -EINVAL;
    }

    if (!has_six_symbols(buf, count)) {
        printk(KERN_ERR "Invalid input: Must have max 6 symbols\n");
        return -EINVAL;
    }

    sscanf(buf,"%x",&raba2);
    
    writel(raba2, SYKT_GPIO_ARG2_ADDR);
    return count;
}


static ssize_t raba1_show(struct kobject *kobj,struct kobj_attribute *attr, char *buf){
    raba1 = readl(SYKT_GPIO_ARG1_ADDR);
    return sprintf(buf, "%x", raba1);
}


static ssize_t raba2_show(struct kobject *kobj,struct kobj_attribute *attr, char *buf){
    raba2 = readl(SYKT_GPIO_ARG2_ADDR);
    return sprintf(buf, "%x", raba2);
}


static ssize_t rabw_store(struct kobject *kobj,struct kobj_attribute *attr,const char *buf, size_t count){
    
     if (!is_hex(buf, count)) {
        printk(KERN_ERR "Invalid hex string: %.*s\n", (int)count, buf);
        return -EINVAL;
    }

    sscanf(buf,"%x",&rabw);

    writel(rabw, SYKT_GPIO_RESULT_ADDR);
    return count;
}


static ssize_t rabl_store(struct kobject *kobj,struct kobj_attribute *attr,const char *buf, size_t count){
   
    if (!is_hex(buf, count)) {
        printk(KERN_ERR "Invalid hex string: %.*s\n", (int)count, buf);
        return -EINVAL;
    }

     sscanf(buf,"%x",&rabl);

    writel(rabl, SYKT_GPIO_ONES_ADDR);
    return count;
}



static ssize_t rabw_show(struct kobject *kobj,struct kobj_attribute *attr, char *buf){
    rabw = readl(SYKT_GPIO_RESULT_ADDR);
    return sprintf(buf, "%x", rabw);
}




static ssize_t rabl_show(struct kobject *kobj,struct kobj_attribute *attr, char *buf){
    rabl = readl(SYKT_GPIO_ONES_ADDR);
    return sprintf(buf, "%x", rabl);
}


static ssize_t rabb_show(struct kobject *kobj,struct kobj_attribute *attr, char *buf){
    rabb = readl(SYKT_GPIO_STATUS_ADDR);
    return sprintf(buf, "%x", rabb);
}

static ssize_t rabb_store(struct kobject *kobj, struct kobj_attribute *attr,const char *buf, size_t count){
    
    if (!is_hex(buf, count)) {
        printk(KERN_ERR "Invalid hex string: %.*s\n", (int)count, buf);
        return -EINVAL;
    }

    sscanf(buf,"%x",&rabb);
       
	writel(rabb, SYKT_GPIO_STATUS_ADDR);
    return count;
}


static struct kobj_attribute raba1_attr = __ATTR(raba1, 0660, raba1_show, raba1_store);
static struct kobj_attribute raba2_attr = __ATTR(raba2, 0660, raba2_show, raba2_store);
static struct kobj_attribute rabw_attr = __ATTR(rabw, 0660, rabw_show, rabw_store);
static struct kobj_attribute rabl_attr = __ATTR(rabl, 0660, rabl_show, rabl_store);
static struct kobj_attribute rabb_attr = __ATTR(rabb, 0660, rabb_show, rabb_store);

//makra



int my_init_module(void){
printk(KERN_INFO "Init my sykt module.\n");
baseptr=ioremap(SYKT_MEM_BASE_ADDR, SYKT_MEM_SIZE);

kobj_ref = kobject_create_and_add("sykt",kernel_kobj);
if (!kobj_ref) {
    printk(KERN_INFO "Failed to create kobject.\n");
}

if (sysfs_create_file(kobj_ref, &raba1_attr.attr))
{
    printk(KERN_INFO "Cannot create sysfs file......\n");
}
if (sysfs_create_file(kobj_ref, &raba2_attr.attr))
{
    printk(KERN_INFO "Cannot create sysfs file......\n");
    sysfs_remove_file(kernel_kobj, &raba1_attr.attr);
}
if (sysfs_create_file(kobj_ref, &rabw_attr.attr))
{
    printk(KERN_INFO "Cannot create sysfs file......\n");
    sysfs_remove_file(kernel_kobj, &raba1_attr.attr);
    sysfs_remove_file(kernel_kobj, &raba2_attr.attr);
}
if (sysfs_create_file(kobj_ref, &rabl_attr.attr))
{
    printk(KERN_INFO "Cannot create sysfs file......\n");
    sysfs_remove_file(kernel_kobj, &raba1_attr.attr);
    sysfs_remove_file(kernel_kobj, &raba2_attr.attr);
    sysfs_remove_file(kernel_kobj, &rabw_attr.attr);
}
if (sysfs_create_file(kobj_ref, &rabb_attr.attr))
{
    printk(KERN_INFO "Cannot create sysfs file......\n");
    sysfs_remove_file(kernel_kobj, &raba1_attr.attr);
    sysfs_remove_file(kernel_kobj, &raba2_attr.attr);
    sysfs_remove_file(kernel_kobj, &rabw_attr.attr);
    sysfs_remove_file(kernel_kobj, &rabl_attr.attr);
}

return 0;


}
void my_cleanup_module(void)
{
printk(KERN_INFO "Cleanup my sykt module.\n");
writel(SYKT_EXIT | ((SYKT_EXIT_CODE) << 16), baseptr);
kobject_put(kobj_ref);
sysfs_remove_file(kernel_kobj, &raba1_attr.attr);
sysfs_remove_file(kernel_kobj, &raba2_attr.attr);
sysfs_remove_file(kernel_kobj, &rabw_attr.attr);
sysfs_remove_file(kernel_kobj, &rabl_attr.attr);
sysfs_remove_file(kernel_kobj, &rabb_attr.attr);
iounmap(baseptr);
}

module_init(my_init_module)
module_exit(my_cleanup_module)

